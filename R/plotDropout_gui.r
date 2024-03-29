################################################################################
# CHANGE LOG (last 20 changes)
# 07.07.2023: Fixed Error in !is.na(.gData) && !is.null(.gData) in coercion to 'logical(1)
# 10.09.2022: Compacted the gui. Fixed narrow dropdowns. Removed destroy workaround.
# 04.08.2022: Added a reference.
# 01.06.2020: Fixed "object 'val_obj' not found" when pressing plot buttons.
# 25.04.2020: Added language support.
# 23.02.2019: Compacted and tweaked gui for tcltk.
# 17.02.2019: Fixed Error in if (svalue(savegui_chk)) { : argument is of length zero (tcltk)
# 13.07.2017: Fixed issue with button handlers.
# 13.07.2017: Fixed expanded 'gexpandgroup'.
# 13.07.2017: Fixed narrow dropdown with hidden argument ellipsize = "none".
# 07.07.2017: Replaced 'droplist' with 'gcombobox'.
# 07.07.2017: Removed argument 'border' for 'gbutton'.
# 29.04.2016: 'Save as' textbox expandable.
# 29.04.2016: Removed unints from automatic titles.
# 21.04.2016: Added new option 'Round to digits' (x-tick labels).
# 11.11.2015: Added importFrom ggplot2.
# 29.08.2015: Added importFrom.
# 16.05.2015: Fixed issue#10 colors hardcoded as ESX17 for dotplot.
# 11.10.2014: Added 'focus', added 'parent' parameter.
# 28.06.2014: Added help button and moved save gui checkbox.

#' @title Plot Drop-out Events
#'
#' @description
#' GUI simplifying the creation of plots from dropout data.
#'
#' @details Plot dropout data as heatmap arranged by, average peak height,
#' amount, concentration, or sample name. It is also possible to plot the
#' empirical cumulative distribution (ecdp) of the peak heights of surviving heterozygote
#' alleles (with dropout of the partner allele), or a dotplot of all dropout events.
#' The peak height of homozygote alleles can be included in the ecdp.
#' Automatic plot titles can be replaced by custom titles.
#' A name for the result is automatically suggested.
#' The resulting plot can be saved as either a plot object or as an image.
#' @param env environment in which to search for data frames and save result.
#' @param savegui logical indicating if GUI settings should be saved in the environment.
#' @param debug logical indicating printing debug information.
#' @param parent widget to get focus when finished.
#'
#' @references
#' Antoinette A. Westen, Laurens J.W. Grol, Joyce Harteveld, Anuska S.Matai,
#' Peter de Knijff, Titia Sijen, Assessment of the stochastic threshold, back- and
#' forward stutter filters and low template techniques for NGM,
#' Forensic Science International: Genetetics, Volume 6, Issue 6, December 2012,
#' Pages 708-715, ISSN 1872-4973, 10.1016/j.fsigen.2012.05.001.
#'  \doi{10.1016/j.fsigen.2012.05.001}
#'
#' @return TRUE
#'
#' @export
#'
#' @importFrom scales pretty_breaks
#' @importFrom utils help str
#' @importFrom grDevices rgb
#' @importFrom ggplot2 ggplot aes_string geom_tile scale_fill_manual guides
#'  guide_legend theme element_text labs ylab xlab scale_y_discrete scale_x_discrete
#'  stat_ecdf scale_colour_discrete scale_x_continuous scale_y_continuous
#'  coord_cartesian geom_point position_jitter scale_colour_manual
#'
#' @seealso \url{https://ggplot2.tidyverse.org/} for details on plot settings.

plotDropout_gui <- function(env = parent.frame(), savegui = NULL, debug = FALSE, parent = NULL) {
  # Global variables.
  .gData <- NULL
  .gDataColumns <- NULL
  .gPlot <- NULL

  # Language ------------------------------------------------------------------

  # Get this functions name from call.
  fnc <- as.character(match.call()[[1]])

  if (debug) {
    print(paste("IN:", fnc))
  }

  # Default strings.
  strWinTitle <- "Plot dropout data"
  strChkGui <- "Save GUI settings"
  strBtnHelp <- "Help"
  strFrmDataset <- "Dataset and kit"
  strLblDataset <- "Dataset:"
  strLblKit <- "Kit:"
  strDrpDataset <- "<Select dataset>"
  strFrmOptions <- "Options"
  strChkOverride <- "Override automatic titles"
  strLblTitlePlot <- "Plot title:"
  strLblTitleX <- "X title:"
  strLblTitleY <- "Y title:"
  strExpAxes <- "Axes (applies to continous axes)"
  strLblNB <- "NB! Must provide both min and max value."
  strLblLimitY <- "Limit Y axis (min-max)"
  strLblLimitX <- "Limit X axis (min-max)"
  strExpLabels <- "X labels"
  strLblRound <- "Round to digits:"
  strLblSize <- "Text size (pts):"
  strLblAngle <- "Angle:"
  strLblJustification <- "Justification (v/h):"
  strFrmPlot <- "Plot heatmap by"
  strBtnH <- "Average peak height"
  strBtnAmount <- "Amount"
  strBtnConcentration <- "Concentration"
  strBtnSample <- "Sample"
  strBtnProcessing <- "Processing..."
  strFrmOther <- "Other plots"
  strBtnECDP <- "ecdp"
  strTipECDP <- "Empirical cumulative distribution plot"
  strChkHom <- "Plot homozygous peaks."
  strBtnDot <- "Dotplot"
  strFrmSave <- "Save as"
  strLblSave <- "Name for result:"
  strBtnSaveObject <- "Save as object"
  strBtnSaveImage <- "Save as image"
  strBtnObjectSaved <- "Object saved"
  strLblMainTitle <- "Allele and locus dropout"
  strLblMainTitleECDP <- "Empirical cumulative distribution for"
  strLblMainTitleAnd <- "and"
  strLblMainTitleHeterozygous <- "heterozygous alleles (with dropout of the sister allele)"
  strLblMainTitleHomozygous <- "homozygous peaks"
  strLblXTitleAverage <- "Average peak height"
  strLblXTitleAmount <- "Amount amplified DNA"
  strLblXTitleConcentration <- "Concentration"
  strLblXTitleSample <- "Sample name"
  strLblXTitleHeight <- "Peak height (RFU)"
  strLblXTitleSurvivingHeight <- "Peak height of surviving allele (RFU)"
  strLblYTitleMarker <- "Marker"
  strLblYTitleCP <- "Cumulative probability"
  strMsgNotDf <- "Data set must be a data.frame!"
  strMsgTitleError <- "Error"

  # Get strings from language file.
  dtStrings <- getStrings(gui = fnc)

  # If language file is found.
  if (!is.null(dtStrings)) {
    # Get language strings, use default if not found.

    strtmp <- dtStrings["strWinTitle"]$value
    strWinTitle <- ifelse(is.na(strtmp), strWinTitle, strtmp)

    strtmp <- dtStrings["strChkGui"]$value
    strChkGui <- ifelse(is.na(strtmp), strChkGui, strtmp)

    strtmp <- dtStrings["strBtnHelp"]$value
    strBtnHelp <- ifelse(is.na(strtmp), strBtnHelp, strtmp)

    strtmp <- dtStrings["strFrmDataset"]$value
    strFrmDataset <- ifelse(is.na(strtmp), strFrmDataset, strtmp)

    strtmp <- dtStrings["strLblDataset"]$value
    strLblDataset <- ifelse(is.na(strtmp), strLblDataset, strtmp)

    strtmp <- dtStrings["strLblKit"]$value
    strLblKit <- ifelse(is.na(strtmp), strLblKit, strtmp)

    strtmp <- dtStrings["strDrpDataset"]$value
    strDrpDataset <- ifelse(is.na(strtmp), strDrpDataset, strtmp)

    strtmp <- dtStrings["strFrmOptions"]$value
    strFrmOptions <- ifelse(is.na(strtmp), strFrmOptions, strtmp)

    strtmp <- dtStrings["strChkOverride"]$value
    strChkOverride <- ifelse(is.na(strtmp), strChkOverride, strtmp)

    strtmp <- dtStrings["strLblTitlePlot"]$value
    strLblTitlePlot <- ifelse(is.na(strtmp), strLblTitlePlot, strtmp)

    strtmp <- dtStrings["strLblTitleX"]$value
    strLblTitleX <- ifelse(is.na(strtmp), strLblTitleX, strtmp)

    strtmp <- dtStrings["strLblTitleY"]$value
    strLblTitleY <- ifelse(is.na(strtmp), strLblTitleY, strtmp)

    strtmp <- dtStrings["strExpAxes"]$value
    strExpAxes <- ifelse(is.na(strtmp), strExpAxes, strtmp)

    strtmp <- dtStrings["strLblNB"]$value
    strLblNB <- ifelse(is.na(strtmp), strLblNB, strtmp)

    strtmp <- dtStrings["strLblLimitY"]$value
    strLblLimitY <- ifelse(is.na(strtmp), strLblLimitY, strtmp)

    strtmp <- dtStrings["strLblLimitX"]$value
    strLblLimitX <- ifelse(is.na(strtmp), strLblLimitX, strtmp)

    strtmp <- dtStrings["strExpLabels"]$value
    strExpLabels <- ifelse(is.na(strtmp), strExpLabels, strtmp)

    strtmp <- dtStrings["strLblRound"]$value
    strLblRound <- ifelse(is.na(strtmp), strLblRound, strtmp)

    strtmp <- dtStrings["strLblSize"]$value
    strLblSize <- ifelse(is.na(strtmp), strLblSize, strtmp)

    strtmp <- dtStrings["strLblAngle"]$value
    strLblAngle <- ifelse(is.na(strtmp), strLblAngle, strtmp)

    strtmp <- dtStrings["strLblJustification"]$value
    strLblJustification <- ifelse(is.na(strtmp), strLblJustification, strtmp)

    strtmp <- dtStrings["strFrmPlot"]$value
    strFrmPlot <- ifelse(is.na(strtmp), strFrmPlot, strtmp)

    strtmp <- dtStrings["strBtnH"]$value
    strBtnH <- ifelse(is.na(strtmp), strBtnH, strtmp)

    strtmp <- dtStrings["strBtnAmount"]$value
    strBtnAmount <- ifelse(is.na(strtmp), strBtnAmount, strtmp)

    strtmp <- dtStrings["strBtnConcentration"]$value
    strBtnConcentration <- ifelse(is.na(strtmp), strBtnConcentration, strtmp)

    strtmp <- dtStrings["strBtnSample"]$value
    strBtnSample <- ifelse(is.na(strtmp), strBtnSample, strtmp)

    strtmp <- dtStrings["strBtnProcessing"]$value
    strBtnProcessing <- ifelse(is.na(strtmp), strBtnProcessing, strtmp)

    strtmp <- dtStrings["strFrmOther"]$value
    strFrmOther <- ifelse(is.na(strtmp), strFrmOther, strtmp)

    strtmp <- dtStrings["strBtnECDP"]$value
    strBtnECDP <- ifelse(is.na(strtmp), strBtnECDP, strtmp)

    strtmp <- dtStrings["strTipECDP"]$value
    strTipECDP <- ifelse(is.na(strtmp), strTipECDP, strtmp)

    strtmp <- dtStrings["strChkHom"]$value
    strChkHom <- ifelse(is.na(strtmp), strChkHom, strtmp)

    strtmp <- dtStrings["strBtnDot"]$value
    strBtnDot <- ifelse(is.na(strtmp), strBtnDot, strtmp)

    strtmp <- dtStrings["strFrmSave"]$value
    strFrmSave <- ifelse(is.na(strtmp), strFrmSave, strtmp)

    strtmp <- dtStrings["strLblSave"]$value
    strLblSave <- ifelse(is.na(strtmp), strLblSave, strtmp)

    strtmp <- dtStrings["strBtnSaveObject"]$value
    strBtnSaveObject <- ifelse(is.na(strtmp), strBtnSaveObject, strtmp)

    strtmp <- dtStrings["strBtnSaveImage"]$value
    strBtnSaveImage <- ifelse(is.na(strtmp), strBtnSaveImage, strtmp)

    strtmp <- dtStrings["strBtnObjectSaved"]$value
    strBtnObjectSaved <- ifelse(is.na(strtmp), strBtnObjectSaved, strtmp)

    strtmp <- dtStrings["strLblMainTitle"]$value
    strLblMainTitle <- ifelse(is.na(strtmp), strLblMainTitle, strtmp)

    strtmp <- dtStrings["strLblMainTitleECDP"]$value
    strLblMainTitleECDP <- ifelse(is.na(strtmp), strLblMainTitleECDP, strtmp)

    strtmp <- dtStrings["strLblMainTitleAnd"]$value
    strLblMainTitleAnd <- ifelse(is.na(strtmp), strLblMainTitleAnd, strtmp)

    strtmp <- dtStrings["strLblMainTitleHeterozygous"]$value
    strLblMainTitleHeterozygous <- ifelse(is.na(strtmp), strLblMainTitleHeterozygous, strtmp)

    strtmp <- dtStrings["strLblMainTitleHomozygous"]$value
    strLblMainTitleHomozygous <- ifelse(is.na(strtmp), strLblMainTitleHomozygous, strtmp)

    strtmp <- dtStrings["strLblXTitleAverage"]$value
    strLblXTitleAverage <- ifelse(is.na(strtmp), strLblXTitleAverage, strtmp)

    strtmp <- dtStrings["strLblXTitleAmount"]$value
    strLblXTitleAmount <- ifelse(is.na(strtmp), strLblXTitleAmount, strtmp)

    strtmp <- dtStrings["strLblXTitleConcentration"]$value
    strLblXTitleConcentration <- ifelse(is.na(strtmp), strLblXTitleConcentration, strtmp)

    strtmp <- dtStrings["strLblXTitleSample"]$value
    strLblXTitleSample <- ifelse(is.na(strtmp), strLblXTitleSample, strtmp)

    strtmp <- dtStrings["strLblXTitleHeight"]$value
    strLblXTitleHeight <- ifelse(is.na(strtmp), strLblXTitleHeight, strtmp)

    strtmp <- dtStrings["strLblXTitleSurvivingHeight"]$value
    strLblXTitleSurvivingHeight <- ifelse(is.na(strtmp), strLblXTitleSurvivingHeight, strtmp)

    strtmp <- dtStrings["strLblYTitleMarker"]$value
    strLblYTitleMarker <- ifelse(is.na(strtmp), strLblYTitleMarker, strtmp)

    strtmp <- dtStrings["strLblYTitleCP"]$value
    strLblYTitleCP <- ifelse(is.na(strtmp), strLblYTitleCP, strtmp)

    strtmp <- dtStrings["strMsgNotDf"]$value
    strMsgNotDf <- ifelse(is.na(strtmp), strMsgNotDf, strtmp)

    strtmp <- dtStrings["strMsgTitleError"]$value
    strMsgTitleError <- ifelse(is.na(strtmp), strMsgTitleError, strtmp)
  }

  # WINDOW ####################################################################

  # Main window.
  w <- gwindow(title = strWinTitle, visible = FALSE)

  # Runs when window is closed.
  addHandlerUnrealize(w, handler = function(h, ...) {
    # Save GUI state.
    .saveSettings()

    # Focus on parent window.
    if (!is.null(parent)) {
      focus(parent)
    }

    # Destroy window.
    return(FALSE)
  })

  # Vertical main group.
  gv <- ggroup(
    horizontal = FALSE,
    spacing = 1,
    use.scrollwindow = FALSE,
    container = w,
    expand = TRUE
  )

  # Help button group.
  gh <- ggroup(container = gv, expand = FALSE, fill = "both")

  savegui_chk <- gcheckbox(text = strChkGui, checked = FALSE, container = gh)

  addSpring(gh)

  help_btn <- gbutton(text = strBtnHelp, container = gh)

  addHandlerChanged(help_btn, handler = function(h, ...) {
    # Open help page for function.
    print(help(fnc, help_type = "html"))
  })

  # FRAME 0 ###################################################################

  f0 <- gframe(
    text = strFrmDataset,
    horizontal = FALSE,
    spacing = 1,
    container = gv
  )

  # Dataset -------------------------------------------------------------------

  g0 <- ggroup(container = f0, spacing = 1, expand = TRUE, fill = "x")

  glabel(text = strLblDataset, container = g0)

  dataset_drp <- gcombobox(
    items = c(
      strDrpDataset,
      listObjects(
        env = env,
        obj.class = "data.frame"
      )
    ),
    selected = 1,
    editable = FALSE,
    container = g0,
    ellipsize = "none",
    expand = TRUE,
    fill = "x"
  )

  # Kit -----------------------------------------------------------------------

  g1 <- ggroup(container = f0, spacing = 1, expand = TRUE, fill = "x")

  glabel(text = strLblKit, container = g1)

  kit_drp <- gcombobox(
    items = getKit(),
    selected = 1,
    editable = FALSE,
    container = g1,
    ellipsize = "none",
    expand = TRUE,
    fill = "x"
  )

  addHandlerChanged(dataset_drp, handler = function(h, ...) {
    val_obj <- svalue(dataset_drp)

    # Check if suitable.
    requiredCol <- c(
      "Sample.Name", "Marker", "Allele", "Height",
      "Dropout", "Rfu", "Heterozygous"
    )
    ok <- checkDataset(
      name = val_obj, reqcol = requiredCol,
      env = env, parent = w, debug = debug
    )

    if (ok) {
      # Load or change components.
      .gData <<- get(val_obj, envir = env)
      .gDataColumns <<- names(.gData)

      # Suggest name.
      svalue(f5_save_edt) <- paste(val_obj, "_ggplot", sep = "")
      # Detect kit.
      kitIndex <- detectKit(.gData, index = TRUE)
      # Select in dropdown.
      svalue(kit_drp, index = TRUE) <- kitIndex

      # Enable plot buttons.
      enabled(f7_plot_h_btn) <- TRUE
      enabled(f7_plot_amount_btn) <- TRUE
      enabled(f7_plot_conc_btn) <- TRUE
      enabled(f7_plot_sample_btn) <- TRUE
      enabled(f8_plot_ecdf_btn) <- TRUE
      enabled(f8_plot_dot_btn) <- TRUE
    } else {
      # Reset components.
      .gData <<- NULL
      .gDataColumns <<- NULL
      svalue(f5_save_edt) <- ""
    }
  })

  # FRAME 1 ###################################################################

  f1 <- gframe(
    text = strFrmOptions,
    horizontal = FALSE,
    spacing = 1,
    container = gv
  )

  titles_chk <- gcheckbox(
    text = strChkOverride,
    checked = FALSE, container = f1
  )


  addHandlerChanged(titles_chk, handler = function(h, ...) {
    .updateGui()
  })

  titles_group <- ggroup(
    container = f1, spacing = 1, horizontal = FALSE,
    expand = TRUE, fill = TRUE
  )

  # Legends
  glabel(text = strLblTitlePlot, container = titles_group, anchor = c(-1, 0))
  title_edt <- gedit(expand = TRUE, fill = TRUE, container = titles_group)

  glabel(text = strLblTitleX, container = titles_group, anchor = c(-1, 0))
  x_title_edt <- gedit(expand = TRUE, fill = TRUE, container = titles_group)

  glabel(text = strLblTitleY, container = titles_group, anchor = c(-1, 0))
  y_title_edt <- gedit(expand = TRUE, fill = TRUE, container = titles_group)

  # FRAME 7 ###################################################################

  f7 <- gframe(
    text = strFrmPlot,
    horizontal = TRUE,
    container = gv
  )

  f7_plot_h_btn <- gbutton(text = strBtnH, container = f7)

  f7_plot_amount_btn <- gbutton(text = strBtnAmount, container = f7)

  f7_plot_conc_btn <- gbutton(text = strBtnConcentration, container = f7)

  f7_plot_sample_btn <- gbutton(text = strBtnSample, container = f7)

  addHandlerChanged(f7_plot_h_btn, handler = function(h, ...) {
    val_obj <- svalue(dataset_drp)

    # Check if suitable for plot.
    requiredCol <- c("Sample.Name", "Marker", "Dropout", "H")

    ok <- checkDataset(
      name = val_obj, reqcol = requiredCol,
      env = env, parent = w, debug = debug
    )

    if (ok) {
      enabled(f7_plot_h_btn) <- FALSE
      .plotDropout(what = "heat_h")
      enabled(f7_plot_h_btn) <- TRUE
    }

    # Change save button.
    svalue(f5_save_btn) <- strBtnSaveObject
    enabled(f5_save_btn) <- TRUE
  })

  addHandlerChanged(f7_plot_amount_btn, handler = function(h, ...) {
    val_obj <- svalue(dataset_drp)

    # Check if suitable for plot.
    requiredCol <- c("Sample.Name", "Marker", "Dropout", "Amount")

    ok <- checkDataset(
      name = val_obj, reqcol = requiredCol,
      env = env, parent = w, debug = debug
    )

    if (ok) {
      enabled(f7_plot_amount_btn) <- FALSE
      .plotDropout(what = "heat_amount")
      enabled(f7_plot_amount_btn) <- TRUE
    }

    # Change save button.
    svalue(f5_save_btn) <- strBtnSaveObject
    enabled(f5_save_btn) <- TRUE
  })

  addHandlerChanged(f7_plot_conc_btn, handler = function(h, ...) {
    val_obj <- svalue(dataset_drp)

    # Check if suitable for plot.
    requiredCol <- c("Sample.Name", "Marker", "Dropout", "Concentration")

    ok <- checkDataset(
      name = val_obj, reqcol = requiredCol,
      env = env, parent = w, debug = debug
    )

    if (ok) {
      enabled(f7_plot_conc_btn) <- FALSE
      .plotDropout(what = "heat_conc")
      enabled(f7_plot_conc_btn) <- TRUE
    }

    # Change save button.
    svalue(f5_save_btn) <- strBtnSaveObject
    enabled(f5_save_btn) <- TRUE
  })

  addHandlerChanged(f7_plot_sample_btn, handler = function(h, ...) {
    val_obj <- svalue(dataset_drp)

    # Check if suitable for plot.
    requiredCol <- c("Sample.Name", "Marker", "Dropout")

    ok <- checkDataset(
      name = val_obj, reqcol = requiredCol,
      env = env, parent = w, debug = debug
    )

    if (ok) {
      enabled(f7_plot_sample_btn) <- FALSE
      .plotDropout(what = "sample")
      enabled(f7_plot_sample_btn) <- TRUE
    }

    # Change save button.
    svalue(f5_save_btn) <- strBtnSaveObject
    enabled(f5_save_btn) <- TRUE
  })

  # FRAME 8 ###################################################################

  f8 <- gframe(
    text = strFrmOther,
    horizontal = TRUE,
    container = gv
  )

  f8_plot_ecdf_btn <- gbutton(text = strBtnECDP, container = f8)
  tooltip(f8_plot_ecdf_btn) <- strTipECDP

  f8_hom_chk <- gcheckbox(
    text = strChkHom,
    checked = FALSE,
    container = f8
  )

  f8_plot_dot_btn <- gbutton(text = strBtnDot, container = f8)

  addHandlerChanged(f8_plot_ecdf_btn, handler = function(h, ...) {
    val_obj <- svalue(dataset_drp)

    # Check if suitable for plot.
    requiredCol <- c("Sample.Name", "Marker", "Dropout", "Height", "Heterozygous")

    ok <- checkDataset(
      name = val_obj, reqcol = requiredCol,
      env = env, parent = w, debug = debug
    )

    if (ok) {
      enabled(f8_plot_ecdf_btn) <- FALSE
      .plotDropout(what = "ecdf")
      enabled(f8_plot_ecdf_btn) <- TRUE
    }

    # Change save button.
    svalue(f5_save_btn) <- strBtnSaveObject
    enabled(f5_save_btn) <- TRUE
  })

  addHandlerChanged(f8_plot_dot_btn, handler = function(h, ...) {
    val_obj <- svalue(dataset_drp)

    # Check if suitable for plot.
    requiredCol <- c("Sample.Name", "Marker", "Dropout", "Height", "Heterozygous")

    ok <- checkDataset(
      name = val_obj, reqcol = requiredCol,
      env = env, parent = w, debug = debug
    )

    if (ok) {
      enabled(f8_plot_dot_btn) <- FALSE
      .plotDropout(what = "dot")
      enabled(f8_plot_dot_btn) <- TRUE
    }

    # Change save button.
    svalue(f5_save_btn) <- strBtnSaveObject
    enabled(f5_save_btn) <- TRUE
  })

  # FRAME 5 ###################################################################

  f5 <- gframe(
    text = strFrmSave,
    horizontal = TRUE,
    spacing = 1,
    container = gv
  )

  glabel(text = strLblSave, container = f5)

  f5_save_edt <- gedit(text = "", container = f5, expand = TRUE, fill = TRUE)

  f5_save_btn <- gbutton(text = strBtnSaveObject, container = f5)

  f5_ggsave_btn <- gbutton(text = strBtnSaveImage, container = f5)

  addHandlerClicked(f5_save_btn, handler = function(h, ...) {
    val_name <- svalue(f5_save_edt)

    # Change button.
    blockHandlers(f5_save_btn)
    svalue(f5_save_btn) <- strBtnProcessing
    unblockHandlers(f5_save_btn)
    enabled(f5_save_btn) <- FALSE

    # Save data.
    saveObject(
      name = val_name, object = .gPlot,
      parent = w, env = env, debug = debug
    )

    # Change button.
    blockHandlers(f5_save_btn)
    svalue(f5_save_btn) <- strBtnObjectSaved
    unblockHandlers(f5_save_btn)
  })

  addHandlerChanged(f5_ggsave_btn, handler = function(h, ...) {
    val_name <- svalue(f5_save_edt)

    # Save data.
    ggsave_gui(
      ggplot = .gPlot, name = val_name,
      parent = w, env = env, savegui = savegui, debug = debug
    )
  })

  # ADVANCED OPTIONS ##########################################################

  # FRAME 3 ###################################################################

  e3 <- gexpandgroup(
    text = strExpAxes,
    horizontal = FALSE,
    container = f1
  )

  # Start collapsed.
  visible(e3) <- FALSE

  grid3 <- glayout(container = e3, spacing = 1)

  grid3[1, 1:2] <- glabel(text = strLblLimitY, container = grid3)
  grid3[2, 1] <- e3_y_min_edt <- gedit(text = "", width = 5, container = grid3)
  grid3[2, 2] <- e3_y_max_edt <- gedit(text = "", width = 5, container = grid3)

  grid3[3, 1:2] <- glabel(text = strLblLimitX, container = grid3)
  grid3[4, 1] <- e3_x_min_edt <- gedit(text = "", width = 5, container = grid3)
  grid3[4, 2] <- e3_x_max_edt <- gedit(text = "", width = 5, container = grid3)

  # FRAME 4 ###################################################################

  e4 <- gexpandgroup(
    text = strExpLabels,
    horizontal = FALSE,
    container = f1
  )

  # Start collapsed.
  visible(e4) <- FALSE

  grid4 <- glayout(container = e4)

  grid4[1, 1] <- glabel(text = strLblRound, container = grid4)
  grid4[1, 2] <- e4_round_spb <- gspinbutton(
    from = 0, to = 10, by = 1,
    value = 3, container = grid4
  )

  grid4[2, 1] <- glabel(text = strLblSize, container = grid4)
  grid4[2, 2] <- e4_size_txt <- gedit(text = "10", width = 4, container = grid4)

  grid4[2, 3] <- glabel(text = strLblAngle, container = grid4)
  grid4[2, 4] <- e4_angle_spb <- gspinbutton(
    from = 0, to = 360, by = 1,
    value = 270, container = grid4
  )

  grid4[3, 1] <- glabel(text = strLblJustification, container = grid4)
  grid4[3, 2] <- e4_vjust_spb <- gspinbutton(
    from = 0, to = 1, by = 0.1,
    value = 0.3, container = grid4
  )

  grid4[3, 3] <- e4_hjust_spb <- gspinbutton(
    from = 0, to = 1, by = 0.1,
    value = 0, container = grid4
  )

  # FUNCTIONS #################################################################


  .plotDropout <- function(what) {
    # Get values.
    val_titles <- svalue(titles_chk)
    val_title <- svalue(title_edt)
    val_xtitle <- svalue(x_title_edt)
    val_ytitle <- svalue(y_title_edt)
    val_angle <- as.numeric(svalue(e4_angle_spb))
    val_vjust <- as.numeric(svalue(e4_vjust_spb))
    val_hjust <- as.numeric(svalue(e4_hjust_spb))
    val_size <- as.numeric(svalue(e4_size_txt))
    val_round <- as.numeric(svalue(e4_round_spb))
    val_kit <- svalue(kit_drp)
    val_hom <- svalue(f8_hom_chk)
    val_ymin <- as.numeric(svalue(e3_y_min_edt))
    val_ymax <- as.numeric(svalue(e3_y_max_edt))
    val_xmin <- as.numeric(svalue(e3_x_min_edt))
    val_xmax <- as.numeric(svalue(e3_x_max_edt))

    if (debug) {
      print("val_title")
      print(val_title)
      print("val_xtitle")
      print(val_xtitle)
      print("val_ytitle")
      print(val_ytitle)
      print("val_angle")
      print(val_angle)
      print("val_vjust")
      print(val_vjust)
      print("val_hjust")
      print(val_hjust)
      print("val_size")
      print(val_size)
      print("val_round")
      print(val_round)
      print("val_hom")
      print(val_hom)
      print("str(.gData)")
      print(str(.gData))
    }


    if (is.data.frame(.gData)) {
      # Call functions.

      # Color information.
      if (is.null(.gData$Dye)) {
        .gData <- addColor(data = .gData, kit = val_kit, need = "Dye")
      }

      # Sort by marker in kit
      .gData <- sortMarker(
        data = .gData,
        kit = val_kit,
        add.missing.levels = TRUE
      )


      if (debug) {
        print("Before plot: str(.gData)")
        print(str(.gData))
      }

      # Create custom titles.
      if (val_titles) {
        mainTitle <- val_title
        xTitle <- val_xtitle
        yTitle <- val_ytitle
      }

      # Select what to plot and create default titles.
      if (what == "heat_h") {
        # Create default titles.
        if (!val_titles) {
          mainTitle <- strLblMainTitle
          xTitle <- strLblXTitleAverage
          yTitle <- strLblYTitleMarker
        }

        # Sort according to H.
        if (!is.numeric(.gData$H)) {
          .gData$H <- as.numeric(.gData$H)
          message("'H' converted to numeric.")
        }
        .gData <- .gData[order(.gData$H), ]

        # Add H to sample name.
        .gData$Sample.Name <- paste(.gData$H, " (", .gData$Sample.Name, ")", sep = "")

        # Create factors.
        .gData$Dropout <- factor(.gData$Dropout, levels = c(0, 1, 2))
        .gData$Sample.Name <- factor(.gData$Sample.Name,
          levels = unique(.gData$Sample.Name)
        )

        # Create x labels.
        xlabels <- .gData[!duplicated(.gData[, c("Sample.Name", "H")]), ]$H
        xlabels <- round(as.double(xlabels), digits = 0)

        # Define colours.
        col <- c(rgb(0, 0.737, 0), rgb(1, 0.526, 1), rgb(0.526, 0, 0.526))

        # Create plot.
        gp <- ggplot(.gData, aes_string(x = "Sample.Name", y = "Marker", fill = "Dropout"))
        gp <- gp + geom_tile(colour = "white") # OK
        gp <- gp + scale_fill_manual(
          values = col, name = "Dropout", breaks = c("0", "1", "2"),
          labels = c("none", "allele", "locus")
        )
        gp <- gp + guides(fill = guide_legend(reverse = TRUE)) # OK
        gp <- gp + theme(axis.text.x = element_text(
          angle = val_angle,
          hjust = val_hjust,
          vjust = val_vjust,
          size = val_size
        ))

        gp <- gp + labs(title = mainTitle)
        gp <- gp + ylab(yTitle)
        gp <- gp + xlab(xTitle)

        # Reverse y-axis and relabel x-ticks.
        gp <- gp + scale_y_discrete(limits = rev(levels(.gData$Marker))) +
          scale_x_discrete(labels = formatC(xlabels, 0, format = "f")) +
          theme(axis.text.x = element_text(family = "sans", face = "bold", size = val_size))
      } else if (what == "heat_amount") {
        # Create default titles.
        if (!val_titles) {
          mainTitle <- strLblMainTitle
          xTitle <- strLblXTitleAmount
          yTitle <- strLblYTitleMarker
        }

        # Sort according to average amount of DNA
        if (!is.numeric(.gData$Amount)) {
          .gData$Amount <- as.numeric(.gData$Amount)
          message("'Amount' converted to numeric.")
        }
        .gData <- .gData[order(.gData$Amount), ]

        # Add amount to sample name.
        .gData$Sample.Name <- paste(.gData$Amount, " (", .gData$Sample.Name, ")", sep = "")

        # Create factors.
        .gData$Dropout <- factor(.gData$Dropout, levels = c(0, 1, 2))
        .gData$Sample.Name <- factor(.gData$Sample.Name,
          levels = unique(.gData$Sample.Name)
        )

        # Create x labels.
        xlabels <- .gData[!duplicated(.gData[, c("Sample.Name", "Amount")]), ]$Amount
        xlabels <- round(as.double(xlabels), digits = val_round) # val_round also used below.

        # Define colours.
        col <- c(rgb(0, 0.737, 0), rgb(1, 0.526, 1), rgb(0.526, 0, 0.526))

        # Create plot.
        gp <- ggplot(.gData, aes_string(x = "Sample.Name", y = "Marker", fill = "Dropout"))
        gp <- gp + geom_tile(colour = "white") # OK
        gp <- gp + scale_fill_manual(
          values = col, name = "Dropout", breaks = c("0", "1", "2"),
          labels = c("none", "allele", "locus")
        )
        gp <- gp + guides(fill = guide_legend(reverse = TRUE)) # OK
        gp <- gp + theme(axis.text.x = element_text(
          angle = val_angle,
          hjust = val_hjust,
          vjust = val_vjust,
          size = val_size
        ))
        gp <- gp + labs(title = mainTitle)
        gp <- gp + ylab(yTitle)
        gp <- gp + xlab(xTitle)

        # Reverse y-axis and relabel x-ticks. Note: formatC required for trailing 0.
        gp <- gp + scale_y_discrete(limits = rev(levels(.gData$Marker))) +
          scale_x_discrete(labels = formatC(xlabels, val_round, format = "f")) +
          theme(axis.text.x = element_text(family = "sans", face = "bold", size = val_size))
      } else if (what == "heat_conc") {
        # Sort according to concentration of DNA.

        # Create default titles.
        if (!val_titles) {
          mainTitle <- strLblMainTitle
          xTitle <- strLblXTitleConcentration
          yTitle <- strLblYTitleMarker
        }

        # Sort according to concentration.
        if (!is.numeric(.gData$Concentration)) {
          .gData$Concentration <- as.numeric(.gData$Concentration)
          message("'Concentration' converted to numeric.")
        }
        .gData <- .gData[order(.gData$Concentration), ]

        # Add concentration to sample name.
        .gData$Sample.Name <- paste(.gData$Concentration, " (", .gData$Sample.Name, ")", sep = "")

        # Create factors.
        .gData$Dropout <- factor(.gData$Dropout, levels = c(0, 1, 2))
        .gData$Sample.Name <- factor(.gData$Sample.Name,
          levels = unique(.gData$Sample.Name)
        )

        # Create x labels.
        xlabels <- .gData[!duplicated(.gData[, c("Sample.Name", "Concentration")]), ]$Concentration
        xlabels <- round(as.double(xlabels), digits = val_round) # val_round also used below.

        # Define colours.
        col <- c(rgb(0, 0.737, 0), rgb(1, 0.526, 1), rgb(0.526, 0, 0.526))

        # Create plot.
        gp <- ggplot(.gData, aes_string(x = "Sample.Name", y = "Marker", fill = "Dropout"))
        gp <- gp + geom_tile(colour = "white") # OK
        gp <- gp + scale_fill_manual(
          values = col, name = "Dropout", breaks = c("0", "1", "2"),
          labels = c("none", "allele", "locus")
        )
        gp <- gp + guides(fill = guide_legend(reverse = TRUE)) # OK
        gp <- gp + theme(axis.text.x = element_text(
          angle = val_angle,
          hjust = val_hjust,
          vjust = val_vjust,
          size = val_size
        ))
        gp <- gp + labs(title = mainTitle)
        gp <- gp + ylab(yTitle)
        gp <- gp + xlab(xTitle)

        # Reverse y-axis and relabel x-ticks. Note: formatC required for trailing 0.
        gp <- gp + scale_y_discrete(limits = rev(levels(.gData$Marker))) +
          scale_x_discrete(labels = formatC(xlabels, val_round, format = "f")) +
          theme(axis.text.x = element_text(family = "sans", face = "bold", size = val_size))
      } else if (what == "sample") {
        # Sort according to sample name.

        # Create default titles.
        if (!val_titles) {
          mainTitle <- strLblMainTitle
          xTitle <- strLblXTitleSample
          yTitle <- strLblYTitleMarker
        }

        # Sort according to sample name.
        .gData <- .gData[order(.gData$Sample.Name), ]

        # Create factors.
        .gData$Dropout <- factor(.gData$Dropout)

        # Create x labels.
        xlabels <- .gData[!duplicated(.gData[, "Sample.Name"]), ]$Sample.Name

        # Define colours.
        col <- c(rgb(0, 0.737, 0), rgb(1, 0.526, 1), rgb(0.526, 0, 0.526))

        # Create plot.
        gp <- ggplot(.gData, aes_string(x = "Sample.Name", y = "Marker", fill = "Dropout"))
        gp <- gp + geom_tile(colour = "white") # OK
        gp <- gp + scale_fill_manual(
          values = col, name = "Dropout", breaks = c("0", "1", "2"),
          labels = c("none", "allele", "locus")
        )
        gp <- gp + guides(fill = guide_legend(reverse = TRUE)) # OK
        gp <- gp + theme(axis.text.x = element_text(
          angle = val_angle,
          hjust = val_hjust,
          vjust = val_vjust,
          size = val_size
        ))
        gp <- gp + labs(title = mainTitle)
        gp <- gp + ylab(yTitle)
        gp <- gp + xlab(xTitle)

        # Reverse y-axis and relabel x-ticks.
        gp <- gp + scale_y_discrete(limits = rev(levels(.gData$Marker))) +
          scale_x_discrete(labels = xlabels) +
          theme(axis.text.x = element_text(family = "sans", face = "bold", size = val_size))
      } else if (what == "ecdf") {
        # Plot empirical cumulative distribution.

        # Remove NA in dropout col.
        # NB! THIS HAS TO BE CHANGED WHEN A DROPOUT MODEL HAS BEEN SELECTED!
        n0 <- nrow(.gData)
        .gData <- .gData[!is.na(.gData$Dropout), ]
        n1 <- nrow(.gData)
        message(paste("Analyse ", n1,
          " rows (", n0 - n1,
          " rows with NA in Dropout removed.",
          sep = ""
        ))

        if (val_hom) {
          # Remove locus dropouts.
          # NB! THIS HAS TO BE CHANGED WHEN A DROPOUT MODEL HAS BEEN SELECTED!
          n0 <- nrow(.gData)
          .gData <- .gData[!is.na(.gData$Height), ]
          n1 <- nrow(.gData)
          message(paste("Analyse ", n1,
            " rows (", n0 - n1,
            " NA rows i.e. locus dropout, removed from column 'Height').",
            sep = ""
          ))

          # Remove locus dropout=2.
          # NB! THIS HAS TO BE CHANGED WHEN A DROPOUT MODEL HAS BEEN SELECTED!
          n0 <- nrow(.gData)
          .gData <- .gData[.gData$Dropout != 2, ]
          n1 <- nrow(.gData)
          message(paste("Analyse ", n1,
            " rows (", n0 - n1,
            " rows with 2 in Dropout removed.",
            sep = ""
          ))

          # Remove heterozygous loci without dropout.
          n0 <- nrow(.gData)
          .gData <- .gData[!(.gData$Heterozygous == 1 & .gData$Dropout == 0), ]
          n1 <- nrow(.gData)
          message(paste("Analyse ", n1,
            " rows (", n0 - n1,
            " heterozygous loci without dropout removed.",
            sep = ""
          ))
        } else {
          # Remove non-dropouts.
          n0 <- nrow(.gData)
          .gData <- .gData[.gData$Dropout == 1, ]
          n1 <- nrow(.gData)
          message(paste("Analyse ", n1,
            " rows (", n0 - n1,
            " non-dropouts removed).",
            sep = ""
          ))
        }

        # Create plot.
        if (val_hom) {
          # Create default titles.
          if (!val_titles) {
            mainTitle <- paste(
              strLblMainTitleECDP,
              sum(.gData$Dropout == 1),
              strLblMainTitleHeterozygous, strLblMainTitleAnd,
              sum(.gData$Dropout == 0),
              strLblMainTitleHomozygous
            )
            xTitle <- strLblXTitleHeight
            yTitle <- strLblYTitleCP
          }

          # NB! Convert numeric to character (continous to discrete).
          # To avoid Error: Continuous value supplied to discrete scale.
          .gData$Heterozygous <- as.character(.gData$Heterozygous)

          # With homozygous data and heterozygous dropout data.
          gp <- ggplot(data = .gData, aes_string(x = "Height", color = "Heterozygous"))
          gp <- gp + stat_ecdf(data = subset(.gData, .gData$Heterozygous == "0"))
          gp <- gp + stat_ecdf(data = subset(.gData, .gData$Heterozygous == "1"))

          # Add legend.
          gp <- gp + scale_colour_discrete(
            name = "Alleles",
            breaks = c("0", "1"),
            labels = c("Homozygous", "Heterozygous")
          )
        } else {
          # Create default titles.
          if (!val_titles) {
            mainTitle <- paste(
              strLblMainTitleECDP,
              sum(.gData$Dropout == 1),
              strLblMainTitleHeterozygous
            )
            xTitle <- strLblXTitleSurvivingHeight
            yTitle <- strLblYTitleCP
          }

          # With heterozygous dropout data.
          gp <- ggplot(.gData) +
            stat_ecdf(aes_string(x = "Height"))
        }
        # TODO: Add optional threshold line.
        # Fn(t) = #{xi <= t}/n = 1/n sum(i=1,n) Indicator(xi <= t).
        # x = rfu, Fn(t) = probability
        # Or bootstrap for "confidence" interval..

        # Add titles and settings.
        gp <- gp + theme(axis.text.x = element_text(
          angle = val_angle,
          vjust = val_vjust,
          size = val_size
        ))
        gp <- gp + labs(title = mainTitle)
        gp <- gp + ylab(yTitle)
        gp <- gp + xlab(xTitle)
        gp <- gp + scale_x_continuous(breaks = scales::pretty_breaks())
        gp <- gp + scale_y_continuous(breaks = seq(0, 1, 0.1))

        # Restrict y axis.
        if (!is.na(val_ymin) && !is.na(val_ymax)) {
          val_y <- c(val_ymin, val_ymax)
        } else {
          val_y <- NULL
        }
        # Restrict x axis.
        if (!is.na(val_xmin) && !is.na(val_xmax)) {
          val_x <- c(val_xmin, val_xmax)
        } else {
          val_x <- NULL
        }
        # Zoom in without dropping observations.
        gp <- gp + coord_cartesian(xlim = val_x, ylim = val_y)
      } else if (what == "dot") {
        # Plot dropouts per locus.

        # NA heights.
        n0 <- nrow(.gData)
        .gData <- .gData[!is.na(.gData$Height), ]
        n1 <- nrow(.gData)
        message(paste("Analyse ", n1,
          " rows (", n0 - n1,
          " NA rows removed from column 'Height').",
          sep = ""
        ))

        # NA Dropouts.
        n0 <- nrow(.gData)
        .gData <- .gData[!is.na(.gData$Dropout), ]
        n1 <- nrow(.gData)
        message(paste("Analyse ", n1,
          " rows (", n0 - n1,
          " NA rows removed from column 'Dropout').",
          sep = ""
        ))

        # Remove non-dropouts.
        n0 <- nrow(.gData)
        .gData <- .gData[.gData$Dropout == 1, ]
        n1 <- nrow(.gData)
        message(paste("Analyse ", n1,
          " rows (", n0 - n1,
          " non-dropouts removed).",
          sep = ""
        ))

        # Create default titles.
        if (!val_titles) {
          mainTitle <- paste(nrow(.gData), strLblMainTitleHeterozygous)
          xTitle <- strLblYTitleMarker
          yTitle <- strLblXTitleSurvivingHeight
        }

        # Create plot.
        plotColor <- getKit(kit = val_kit, what = "Color")
        plotColor <- unique(plotColor$Color)
        plotColor <- addColor(plotColor, need = "R.Color", have = "Color")

        # Create plot.
        gp <- ggplot(data = .gData, aes_string(x = "Marker", y = "Height"))

        # NB! This colour is only a grouping variable, NOT plot color.
        gp <- gp + geom_point(
          data = .gData, mapping = aes_string(colour = "Dye"),
          position = position_jitter(height = 0, width = 0.2)
        )

        # Specify colour values must be strings, NOT factors!
        # NB! The plot colours are specified as here as strings.
        # NB! Custom colours work on DATA AS SORTED FACTOR + COLOR CHARACTER.
        gp <- gp + scale_colour_manual(guide = FALSE, values = as.character(plotColor), drop = FALSE)

        # Add titles and settings.
        gp <- gp + theme(axis.text.x = element_text(
          angle = val_angle,
          vjust = val_vjust,
          size = val_size
        ))
        gp <- gp + labs(title = mainTitle)
        gp <- gp + ylab(yTitle)
        gp <- gp + xlab(xTitle)
        # gp <- gp + scale_y_continuous(breaks = seq(0, 1, 0.1))

        # Restrict y axis.
        if (!is.na(val_ymin) && !is.na(val_ymax)) {
          val_y <- c(val_ymin, val_ymax)
        } else {
          val_y <- NULL
        }
        # Restrict x axis.
        if (!is.na(val_xmin) && !is.na(val_xmax)) {
          val_x <- c(val_xmin, val_xmax)
        } else {
          val_x <- NULL
        }
        # Zoom in without dropping observations.
        gp <- gp + coord_cartesian(xlim = val_x, ylim = val_y)
      } else if (what == "heat_mx") {
        #         if(!val_titles){
        #           mainTitle <- "Allele and locus dropout"
        #           xTitle <- "Mixture proportion (Mx)"
        #           yTitle <- "Marker"
        #         }
        #
        #         .gData <- .gData[order(.gData$Sample.Name),]
        #
        #         .gData$Dropout <- factor(.gData$Dropout)
        #
        # Mx Data:
        # .gData <- newdata[order(newdata$Ratio),]
        # .gData <- newdata[order(newdata$Proportion),]

        # Mx data:
        # .gData$Sample.Name<-paste(.gData$Ratio, " (", .gData$Sample.Name, ")", sep="")
        # .gData$Sample.Name<-paste(.gData$Proportion, " (", .gData$Sample.Name, ")", sep="")

        # Mx data:
        # .gData <- .gData [order(.gData$Ratio),]
        # .gData <- .gData [order(.gData$Proportion),]

        # Mx data SGM Plus.
        # .gData<-addColor()
        # .gData<-sortMarker(.gData,"SGM Plus")

        # Mx Data:
        # xlabels<-.gData[!duplicated(.gData[, c("Sample.Name", "Ratio")]), ]$Ratio
        # xlabels<-.gData[!duplicated(.gData[, c("Sample.Name", "Proportion")]), ]$Proportion

        # Mx data:
        # hm.title <- "Heatmap: allele and locus dropout for 'F' SGM Plus (3500)"
        # hm.xlab <- "Proportion"
        # Mx data:

        # gp <- gp + scale_y_discrete(limits = rev(levels(.gData$Marker))) +
        #  scale_x_discrete(labels=formatC(xlabels, 4, format = "f")) +
        #  theme(axis.text.x=element_text(angle=-90, hjust = 0, vjust = 0.4, size = 10))
      }

      # Draw plot.
      print(gp)

      # Store in global variable.
      .gPlot <<- gp
    } else {
      gmessage(
        msg = strMsgNotDf,
        title = strMsgTitleError,
        icon = "error"
      )
    }
  }

  # INTERNAL FUNCTIONS ########################################################

  .updateGui <- function() {
    # Override titles.
    val <- svalue(titles_chk)
    if (val) {
      enabled(titles_group) <- TRUE
    } else {
      enabled(titles_group) <- FALSE
    }
  }

  .loadSavedSettings <- function() {
    # First check status of save flag.
    if (!is.null(savegui)) {
      svalue(savegui_chk) <- savegui
      enabled(savegui_chk) <- FALSE
      if (debug) {
        print("Save GUI status set!")
      }
    } else {
      # Load save flag.
      if (exists(".strvalidator_plotDropout_gui_savegui", envir = env, inherits = FALSE)) {
        svalue(savegui_chk) <- get(".strvalidator_plotDropout_gui_savegui", envir = env)
      }
      if (debug) {
        print("Save GUI status loaded!")
      }
    }
    if (debug) {
      print(svalue(savegui_chk))
    }

    # Then load settings if true.
    if (svalue(savegui_chk)) {
      if (exists(".strvalidator_plotDropout_gui_title", envir = env, inherits = FALSE)) {
        svalue(title_edt) <- get(".strvalidator_plotDropout_gui_title", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_title_chk", envir = env, inherits = FALSE)) {
        svalue(titles_chk) <- get(".strvalidator_plotDropout_gui_title_chk", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_x_title", envir = env, inherits = FALSE)) {
        svalue(x_title_edt) <- get(".strvalidator_plotDropout_gui_x_title", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_y_title", envir = env, inherits = FALSE)) {
        svalue(y_title_edt) <- get(".strvalidator_plotDropout_gui_y_title", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_axes_y_min", envir = env, inherits = FALSE)) {
        svalue(e3_y_min_edt) <- get(".strvalidator_plotDropout_gui_axes_y_min", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_axes_y_max", envir = env, inherits = FALSE)) {
        svalue(e3_y_max_edt) <- get(".strvalidator_plotDropout_gui_axes_y_max", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_axes_x_min", envir = env, inherits = FALSE)) {
        svalue(e3_x_min_edt) <- get(".strvalidator_plotDropout_gui_axes_x_min", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_axes_x_max", envir = env, inherits = FALSE)) {
        svalue(e3_x_max_edt) <- get(".strvalidator_plotDropout_gui_axes_x_max", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_round", envir = env, inherits = FALSE)) {
        svalue(e4_round_spb) <- get(".strvalidator_plotDropout_gui_xlabel_round", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_size", envir = env, inherits = FALSE)) {
        svalue(e4_size_txt) <- get(".strvalidator_plotDropout_gui_xlabel_size", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_angle", envir = env, inherits = FALSE)) {
        svalue(e4_angle_spb) <- get(".strvalidator_plotDropout_gui_xlabel_angle", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_justh", envir = env, inherits = FALSE)) {
        svalue(e4_hjust_spb) <- get(".strvalidator_plotDropout_gui_xlabel_justh", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_justv", envir = env, inherits = FALSE)) {
        svalue(e4_vjust_spb) <- get(".strvalidator_plotDropout_gui_xlabel_justv", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_hom", envir = env, inherits = FALSE)) {
        svalue(f8_hom_chk) <- get(".strvalidator_plotDropout_gui_hom", envir = env)
      }

      if (debug) {
        print("Saved settings loaded!")
      }
    }
  }

  .saveSettings <- function() {
    # Then save settings if true.
    if (svalue(savegui_chk)) {
      assign(x = ".strvalidator_plotDropout_gui_savegui", value = svalue(savegui_chk), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_title", value = svalue(title_edt), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_title_chk", value = svalue(titles_chk), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_x_title", value = svalue(x_title_edt), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_y_title", value = svalue(y_title_edt), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_axes_y_min", value = svalue(e3_y_min_edt), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_axes_y_max", value = svalue(e3_y_max_edt), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_axes_x_min", value = svalue(e3_x_min_edt), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_axes_x_max", value = svalue(e3_x_max_edt), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_xlabel_round", value = svalue(e4_round_spb), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_xlabel_size", value = svalue(e4_size_txt), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_xlabel_angle", value = svalue(e4_angle_spb), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_xlabel_justh", value = svalue(e4_hjust_spb), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_xlabel_justv", value = svalue(e4_vjust_spb), envir = env)
      assign(x = ".strvalidator_plotDropout_gui_hom", value = svalue(f8_hom_chk), envir = env)
    } else { # or remove all saved values if false.

      if (exists(".strvalidator_plotDropout_gui_savegui", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_savegui", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_title", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_title", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_title_chk", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_title_chk", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_x_title", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_x_title", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_y_title", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_y_title", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_axes_y_min", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_axes_y_min", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_axes_y_max", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_axes_y_max", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_axes_x_min", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_axes_x_min", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_axes_x_max", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_axes_x_max", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_round", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_xlabel_round", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_size", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_xlabel_size", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_angle", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_xlabel_angle", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_justh", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_xlabel_justh", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_xlabel_justv", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_xlabel_justv", envir = env)
      }
      if (exists(".strvalidator_plotDropout_gui_hom", envir = env, inherits = FALSE)) {
        remove(".strvalidator_plotDropout_gui_hom", envir = env)
      }


      if (debug) {
        print("Settings cleared!")
      }
    }

    if (debug) {
      print("Settings saved!")
    }
  }

  # END GUI ###################################################################

  # Load GUI settings.
  .loadSavedSettings()
  .updateGui()

  # Show GUI.
  visible(w) <- TRUE
  focus(w)
}
