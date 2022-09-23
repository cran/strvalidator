# NOTE: Column names used for calculations with data.table is declared
# in globals.R to avoid NOTES in R CMD CHECK.

################################################################################
# CHANGE LOG (last 20 changes)
# 01.09.2022: Compacted gui. Fixed narrow dropdowns. Removed destroy workaround.
# 03.03.2020: Fixed reference to function name.
# 29.02.2020: Added language support.
# 17.02.2019: Fixed Error in if (svalue(savegui_chk)) { : argument is of length zero (tcltk)
# 20.07.2018: Fixed dropdown gets blank when dataset is selected.
# 06.08.2017: Added audit trail.
# 13.07.2017: Fixed issue with button handlers.
# 13.07.2017: Fixed narrow dropdown with hidden argument ellipsize = "none".
# 07.07.2017: Replaced 'droplist' with 'gcombobox'.
# 07.07.2017: Removed argument 'border' for 'gbutton'.
# 27.06.2016: Added kit drop-down to fix hardcoded kit in mask plot.
# 27.06.2016: Removed check for reference sample if masking is selected (no harm).
# 16.06.2016: Fixed bug in plot sample masking range.
# 16.06.2016: Now all excluded peaks are marked (not only high peaks).
# 15.06.2016: Prepare button and drop-down menu now disabled while processing.
# 22.05.2016: Added masked data to result for manual investigation.
# 20.05.2016: 'Blocked' changed to 'masked' throughout.
# 25.04.2016: 'Save as' textbox expandable.
# 11.11.2015: Added importFrom ggplot2.
# 21.10.2015: Added attributes.
# 28.08.2015: Added importFrom

#' @title Calculate Analytical Threshold
#'
#' @description
#' GUI wrapper for the \code{\link{maskAT}} and \code{\link{calculateAT}} function.
#'
#' @details
#' Simplifies the use of the \code{\link{calculateAT}} and
#'  \code{\link{calculateAT}} function by providing a graphical user interface.
#'  In addition there are integrated control functions.
#'
#' @param env environment in which to search for data frames and save result.
#' @param savegui logical indicating if GUI settings should be saved in the environment.
#' @param debug logical indicating printing debug information.
#' @param parent widget to get focus when finished.
#'
#' @return TRUE
#'
#' @export
#'
#' @importFrom utils help head str
#' @importFrom graphics title
#' @importFrom ggplot2 ggtitle scale_shape_discrete ggplot facet_wrap geom_point
#'  aes_string scale_colour_manual geom_rect
#'
#' @seealso \code{\link{calculateAT}}, \code{\link{maskAT}},
#'  \code{\link{checkSubset}}


calculateAT_gui <- function(env = parent.frame(), savegui = NULL,
                            debug = FALSE, parent = NULL) {

  # Global variables.
  .gData <- NULL
  .gSamples <- NULL
  .gDataPrep <- NULL
  .gPlot <- NULL
  .gRef <- NULL

  # Language ------------------------------------------------------------------

  # Get this functions name from call.
  fnc <- as.character(match.call()[[1]])

  if (debug) {
    print(paste("IN:", fnc))
  }

  # Default strings.
  strWinTitle <- "Calculate analytical threshold"
  strChkGui <- "Save GUI settings"
  strBtnHelp <- "Help"
  strFrmDataset <- "Datasets"
  strLblDataset <- "Sample dataset:"
  strDrpDefault <- "<Select dataset>"
  strLblSamples <- "samples"
  strLblDatasetRef <- "Reference dataset:"
  strLblRef <- "references"
  strBtnCheck <- "Check subsetting"
  strLblKit <- "Kit:"
  strTipKit <- "Only used to shade masked ranges in plot."
  strFrmOptions <- "Options"
  strChkIgnore <- "Ignore case"
  strChkWord <- "Add word boundaries"
  strChkMaskHigh <- "Mask high peaks"
  strLblMaskHigh <- "Mask all peaks above (RFU): "
  strChkMaskAllele <- "Mask sample alleles"
  strLblDpAllele <- "Range (data points) around known alleles:"
  strChkMaskDye <- "Mask sample alleles per dye channel"
  strChkILS <- "Mask ILS peaks"
  strLblDpPeak <- "Range (data points) around known peak: "
  strLblConf <- "Confidence level 'k' (AT1, AT7): "
  strLblRank <- "Percentile rank threshold (AT2): "
  strLblAlpha <- "Upper confidence 'alpha' (AT4): "
  strFrmPrepare <- "Prepare data and check masking"
  strBtnMask <- "Prepare and mask"
  strDrpDefault2 <- "<Select sample>"
  strBtnSave <- "Save plot"
  strFrmSave <- "Save as"
  strLblSave <- "Name for result:"
  strLblSaveRank <- "Name for percentile rank list:"
  strLblSaveMasked <- "Name for masked raw data:"
  strBtnCalculate <- "Calculate"
  strBtnProcessing <- "Processing..."
  strWinCheck <- "Check subsetting"
  strMsgPlot <- "Click 'Prepare and mask' and select a sample before saving."
  strMsgTitlePlot <- "No plot!"
  strMsgTitleError <- "Error"
  strMsgCheck <- "Data frame is NULL!\n\nMake sure to select a dataset and a reference set"
  strMsgDataset <- "A dataset and a reference dataset must be selected."
  strMsgTitleDataset <- "Datasets not selected"

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

    strtmp <- dtStrings["strDrpDefault"]$value
    strDrpDefault <- ifelse(is.na(strtmp), strDrpDefault, strtmp)

    strtmp <- dtStrings["strLblSamples"]$value
    strLblSamples <- ifelse(is.na(strtmp), strLblSamples, strtmp)

    strtmp <- dtStrings["strLblDatasetRef"]$value
    strLblDatasetRef <- ifelse(is.na(strtmp), strLblDatasetRef, strtmp)

    strtmp <- dtStrings["strLblRef"]$value
    strLblRef <- ifelse(is.na(strtmp), strLblRef, strtmp)

    strtmp <- dtStrings["strBtnCheck"]$value
    strBtnCheck <- ifelse(is.na(strtmp), strBtnCheck, strtmp)

    strtmp <- dtStrings["strLblKit"]$value
    strLblKit <- ifelse(is.na(strtmp), strLblKit, strtmp)

    strtmp <- dtStrings["strTipKit"]$value
    strTipKit <- ifelse(is.na(strtmp), strTipKit, strtmp)

    strtmp <- dtStrings["strFrmOptions"]$value
    strFrmOptions <- ifelse(is.na(strtmp), strFrmOptions, strtmp)

    strtmp <- dtStrings["strChkIgnore"]$value
    strChkIgnore <- ifelse(is.na(strtmp), strChkIgnore, strtmp)

    strtmp <- dtStrings["strChkWord"]$value
    strChkWord <- ifelse(is.na(strtmp), strChkWord, strtmp)

    strtmp <- dtStrings["strChkMaskHigh"]$value
    strChkMaskHigh <- ifelse(is.na(strtmp), strChkMaskHigh, strtmp)

    strtmp <- dtStrings["strLblMaskHigh"]$value
    strLblMaskHigh <- ifelse(is.na(strtmp), strLblMaskHigh, strtmp)

    strtmp <- dtStrings["strChkMaskAllele"]$value
    strChkMaskAllele <- ifelse(is.na(strtmp), strChkMaskAllele, strtmp)

    strtmp <- dtStrings["strLblDpAllele"]$value
    strLblDpAllele <- ifelse(is.na(strtmp), strLblDpAllele, strtmp)

    strtmp <- dtStrings["strChkMaskDye"]$value
    strChkMaskDye <- ifelse(is.na(strtmp), strChkMaskDye, strtmp)

    strtmp <- dtStrings["strChkILS"]$value
    strChkILS <- ifelse(is.na(strtmp), strChkILS, strtmp)

    strtmp <- dtStrings["strLblDpPeak"]$value
    strLblDpPeak <- ifelse(is.na(strtmp), strLblDpPeak, strtmp)

    strtmp <- dtStrings["strLblConf"]$value
    strLblConf <- ifelse(is.na(strtmp), strLblConf, strtmp)

    strtmp <- dtStrings["strLblRank"]$value
    strLblRank <- ifelse(is.na(strtmp), strLblRank, strtmp)

    strtmp <- dtStrings["strLblAlpha"]$value
    strLblAlpha <- ifelse(is.na(strtmp), strLblAlpha, strtmp)

    strtmp <- dtStrings["strFrmPrepare"]$value
    strFrmPrepare <- ifelse(is.na(strtmp), strFrmPrepare, strtmp)

    strtmp <- dtStrings["strBtnMask"]$value
    strBtnMask <- ifelse(is.na(strtmp), strBtnMask, strtmp)

    strtmp <- dtStrings["strDrpDefault2"]$value
    strDrpDefault2 <- ifelse(is.na(strtmp), strDrpDefault2, strtmp)

    strtmp <- dtStrings["strBtnSave"]$value
    strBtnSave <- ifelse(is.na(strtmp), strBtnSave, strtmp)

    strtmp <- dtStrings["strFrmSave"]$value
    strFrmSave <- ifelse(is.na(strtmp), strFrmSave, strtmp)

    strtmp <- dtStrings["strLblSave"]$value
    strLblSave <- ifelse(is.na(strtmp), strLblSave, strtmp)

    strtmp <- dtStrings["strLblSaveRank"]$value
    strLblSaveRank <- ifelse(is.na(strtmp), strLblSaveRank, strtmp)

    strtmp <- dtStrings["strLblSaveMasked"]$value
    strLblSaveMasked <- ifelse(is.na(strtmp), strLblSaveMasked, strtmp)

    strtmp <- dtStrings["strBtnCalculate"]$value
    strBtnCalculate <- ifelse(is.na(strtmp), strBtnCalculate, strtmp)

    strtmp <- dtStrings["strBtnProcessing"]$value
    strBtnProcessing <- ifelse(is.na(strtmp), strBtnProcessing, strtmp)

    strtmp <- dtStrings["strMsgTitlePlot"]$value
    strMsgTitlePlot <- ifelse(is.na(strtmp), strMsgTitlePlot, strtmp)

    strtmp <- dtStrings["strMsgPlot"]$value
    strMsgPlot <- ifelse(is.na(strtmp), strMsgPlot, strtmp)

    strtmp <- dtStrings["strWinCheck"]$value
    strWinCheck <- ifelse(is.na(strtmp), strWinCheck, strtmp)

    strtmp <- dtStrings["strMsgTitleError"]$value
    strMsgTitleError <- ifelse(is.na(strtmp), strMsgTitleError, strtmp)

    strtmp <- dtStrings["strMsgCheck"]$value
    strMsgCheck <- ifelse(is.na(strtmp), strMsgCheck, strtmp)

    strtmp <- dtStrings["strMsgDataset"]$value
    strMsgDataset <- ifelse(is.na(strtmp), strMsgDataset, strtmp)

    strtmp <- dtStrings["strMsgTitleDataset"]$value
    strMsgTitleDataset <- ifelse(is.na(strtmp), strMsgTitleDataset, strtmp)
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
    container = gv,
    expand = FALSE,
    fill = "x"
  )

  # Dataset -------------------------------------------------------------------

  g0 <- ggroup(container = f0, spacing = 1, expand = TRUE, fill = "x")

  glabel(text = strLblDataset, container = g0)

  g0_data_samples_lbl <- glabel(
    text = paste(" 0", strLblSamples),
    container = g0
  )

  # Create default dropdown.
  dfs <- c(strDrpDefault, listObjects(env = env, obj.class = "data.frame"))

  g0_data_drp <- gcombobox(
    items = dfs,
    selected = 1,
    editable = FALSE,
    container = g0,
    ellipsize = "none",
    expand = TRUE,
    fill = "x"
  )

  addHandlerChanged(g0_data_drp, handler = function(h, ...) {
    val_obj <- svalue(g0_data_drp)

    # Check if suitable.
    requiredCol <- c(
      "Dye.Sample.Peak", "Sample.File.Name", "Marker", "Allele",
      "Marker", "Height", "Data.Point"
    )
    ok <- checkDataset(
      name = val_obj, reqcol = requiredCol,
      slim = TRUE, slimcol = c("Allele", "Height", "Data.Point"),
      env = env, parent = w, debug = debug
    )

    if (ok) {
      # Load or change components.

      # get dataset.
      .gData <<- get(val_obj, envir = env)
      svalue(g0_data_samples_lbl) <- paste(
        length(unique(.gData$Sample.File.Name)),
        strLblSamples
      )
      .refresh_sample_drp()
      .gDataPrep <- NULL # Erase any previously prepared data.

      # Suggest a name for result.
      svalue(f4_save1_edt) <- paste(val_obj, "_at", sep = "")
      svalue(f4_save2_edt) <- paste(val_obj, "_rank", sep = "")
      svalue(f4_save3_edt) <- paste(val_obj, "_masked", sep = "")

      # Detect kit.
      kitIndex <- detectKit(data = .gData, index = TRUE, debug = debug)
      # Select in dropdown.
      svalue(g2_kit_drp, index = TRUE) <- kitIndex
    } else {

      # Reset components.
      .gData <<- NULL
      svalue(g0_data_drp, index = TRUE) <- 1
      svalue(g0_data_samples_lbl) <- paste(" 0", strLblSamples)
      svalue(f4_save1_edt) <- ""
      svalue(f4_save2_edt) <- ""
      svalue(f4_save3_edt) <- ""
      .refresh_sample_drp()
      .gDataPrep <- NULL # Erase any previously prepared data.
    }
  })

  # Reference -----------------------------------------------------------------

  g1 <- ggroup(container = f0, spacing = 1, expand = TRUE, fill = "x")
  glabel(text = strLblDatasetRef, container = g1)

  g1_ref_samples_lbl <- glabel(
    text = paste(" 0", strLblRef),
    container = g1
  )

  # NB! dfs defined in previous section.
  g1_ref_drp <- gcombobox(
    items = dfs,
    selected = 1,
    editable = FALSE,
    container = g1,
    ellipsize = "none", expand = TRUE, fill = "x"
  )

  addHandlerChanged(g1_ref_drp, handler = function(h, ...) {
    val_obj <- svalue(g1_ref_drp)

    # Check if suitable.
    requiredCol <- c("Sample.Name", "Marker", "Allele")
    ok <- checkDataset(
      name = val_obj, reqcol = requiredCol,
      slim = TRUE, slimcol = "Allele",
      env = env, parent = w, debug = debug
    )

    if (ok) {
      # Load or change components.

      .gRef <<- get(val_obj, envir = env)
      svalue(g1_ref_samples_lbl) <- paste(
        length(unique(.gRef$Sample.Name)),
        strLblSamples
      )
    } else {

      # Reset components.
      .gRef <<- NULL
      svalue(g1_ref_drp, index = TRUE) <- 1
      svalue(g1_ref_samples_lbl) <- paste(" 0", strLblRef)
    }
  })

  # Kit -----------------------------------------------------------------------

  g2 <- ggroup(container = f0, expand = TRUE, fill = "x")
  glabel(text = strLblKit, container = g2)

  g2_kit_drp <- gcombobox(
    items = getKit(),
    selected = 1,
    editable = FALSE,
    container = g2,
    ellipsize = "none", expand = TRUE, fill = "x"
  )
  tooltip(g2_kit_drp) <- strTipKit

  # CHECK #####################################################################

  check_btn <- gbutton(text = strBtnCheck, expande = TRUE, container = gv)

  addHandlerChanged(check_btn, handler = function(h, ...) {

    # Get values.
    val_data <- .gData
    val_ref <- .gRef
    val_ignore <- svalue(f1_ignore_chk)
    val_word <- svalue(f1_word_chk)

    if (!is.null(.gData) || !is.null(.gRef)) {
      chksubset_w <- gwindow(
        title = strWinCheck,
        visible = FALSE, name = title,
        width = NULL, height = NULL, parent = w,
        handler = NULL, action = NULL
      )

      chksubset_txt <- checkSubset(
        data = val_data,
        ref = val_ref,
        console = FALSE,
        ignore.case = val_ignore,
        word = val_word
      )

      gtext(
        text = chksubset_txt, width = NULL, height = 300, font.attr = NULL,
        wrap = FALSE, container = chksubset_w
      )

      visible(chksubset_w) <- TRUE
    } else {
      gmessage(
        msg = strMsgCheck,
        title = strMsgTitleError,
        icon = "error"
      )
    }
  })

  # FRAME 1 ###################################################################

  f1 <- gframe(
    text = strFrmOptions,
    horizontal = FALSE,
    spacing = 1,
    container = gv
  )

  f1_ignore_chk <- gcheckbox(
    text = strChkIgnore,
    checked = TRUE,
    container = f1
  )

  f1_word_chk <- gcheckbox(
    text = strChkWord,
    checked = FALSE,
    container = f1
  )

  # LAYOUT --------------------------------------------------------------------

  f1g1 <- glayout(container = f1, spacing = 1)

  f1g1[1, 1] <- f1_mask_h_chk <- gcheckbox(
    text = strChkMaskHigh,
    checked = TRUE, container = f1g1
  )
  f1g1[1, 2] <- glabel(text = strLblMaskHigh, anchor = c(-1, 0), container = f1g1)

  f1g1[1, 3] <- f1_mask_h_edt <- gedit(text = "200", width = 6, container = f1g1)

  f1g1[2, 1] <- f1_mask_chk <- gcheckbox(
    text = strChkMaskAllele,
    checked = TRUE, container = f1g1
  )
  f1g1[3, 1] <- f1_mask_d_chk <- gcheckbox(
    text = strChkMaskDye,
    checked = TRUE, container = f1g1
  )
  f1g1[2, 2] <- glabel(text = strLblDpAllele, anchor = c(-1, 0), container = f1g1)
  f1g1[2, 3] <- f1_mask_spb <- gspinbutton(from = 0, to = 100, by = 10, value = 50, container = f1g1)

  f1g1[4, 1] <- f1_mask_ils_chk <- gcheckbox(
    text = strChkILS,
    checked = TRUE, container = f1g1
  )
  f1g1[4, 2] <- glabel(text = strLblDpPeak, anchor = c(-1, 0), container = f1g1)
  f1g1[4, 3] <- f1_mask_ils_spb <- gspinbutton(from = 0, to = 100, by = 20, value = 10, container = f1g1)

  # LAYOUT --------------------------------------------------------------------

  f1g2 <- glayout(container = f1, spacing = 1)

  f1g2[1, 1] <- glabel(text = strLblConf, container = f1g2)
  f1g2[1, 2] <- f1_k_spb <- gspinbutton(from = 0, to = 100, by = 1, value = 3, container = f1g2)


  f1g2[2, 1] <- glabel(text = strLblRank, container = f1g2)
  f1g2[2, 2] <- f1_t_spb <- gspinbutton(from = 0, to = 1, by = 0.01, value = 0.99, container = f1g2)

  f1g2[3, 1] <- glabel(text = strLblAlpha, container = f1g2)
  f1g2[3, 2] <- f1_a_spb <- gspinbutton(from = 0, to = 1, by = 0.01, value = 0.01, container = f1g2)

  # Handlers ------------------------------------------------------------------

  addHandlerChanged(f1_mask_h_chk, handler = function(h, ...) {

    # Update otions.
    .refresh_options()
  })

  addHandlerChanged(f1_mask_chk, handler = function(h, ...) {

    # Update otions.
    .refresh_options()
  })

  addHandlerChanged(f1_mask_ils_chk, handler = function(h, ...) {

    # Update otions.
    .refresh_options()
  })


  # FRAME 3 ###################################################################

  f3 <- gframe(
    text = strFrmPrepare,
    horizontal = TRUE,
    spacing = 1,
    container = gv,
    expand = TRUE,
    fill = "x"
  )

  mask_btn <- gbutton(text = strBtnMask, container = f3)

  f3_sample_drp <- gcombobox(
    items = strDrpDefault2, selected = 1,
    editable = FALSE, container = f3, ellipsize = "none", expand = TRUE, fill = "x"
  )

  save_btn <- gbutton(text = strBtnSave, container = f3)

  addHandlerClicked(mask_btn, handler = function(h, ...) {

    # Get values.
    val_data <- .gData
    val_ref <- .gRef
    val_mask_h <- svalue(f1_mask_h_chk)
    val_mask <- svalue(f1_mask_chk)
    val_mask_d <- svalue(f1_mask_d_chk)
    val_mask_ils <- svalue(f1_mask_ils_chk)
    val_height <- as.numeric(svalue(f1_mask_h_edt))
    val_range <- svalue(f1_mask_spb)
    val_range_ils <- svalue(f1_mask_ils_spb)
    val_ignore <- svalue(f1_ignore_chk)
    val_word <- svalue(f1_word_chk)

    if (debug) {
      print("Read Values:")
      print("val_data")
      print(head(val_data))
      print("val_mask_h")
      print(val_mask_h)
      print("val_mask")
      print(val_mask)
      print("val_range")
      print(val_range)
      print("val_mask_d")
      print(val_mask_d)
      print("val_mask_ils")
      print(val_mask_ils)
      print("val_range_ils")
      print(val_range_ils)
      print("val_ignore")
      print(val_ignore)
      print("val_word")
      print(val_word)
    }

    # Change button.
    blockHandlers(mask_btn)
    svalue(mask_btn) <- strBtnProcessing
    unblockHandlers(mask_btn)
    enabled(mask_btn) <- FALSE
    enabled(f3_sample_drp) <- FALSE

    # Prepare data.
    .gDataPrep <<- maskAT(
      data = val_data, ref = val_ref,
      mask.height = val_mask_h,
      height = val_height,
      mask.sample = val_mask,
      per.dye = val_mask_d,
      range.sample = val_range,
      mask.ils = val_mask_ils,
      range.ils = val_range_ils,
      ignore.case = val_ignore,
      word = val_word,
      debug = debug
    )

    # Change button.
    blockHandlers(mask_btn)
    svalue(mask_btn) <- strBtnMask
    unblockHandlers(mask_btn)
    enabled(mask_btn) <- TRUE
    enabled(f3_sample_drp) <- TRUE

    # Unselect sample.
    svalue(f3_sample_drp, index = TRUE) <- 1
  })

  addHandlerChanged(f3_sample_drp, handler = function(h, ...) {

    # Get values.
    val_sample <- svalue(f3_sample_drp)

    if (!is.null(.gDataPrep) & !is.null(val_sample)) {

      # Get values.
      val_mask_h <- svalue(f1_mask_h_chk)
      val_mask <- svalue(f1_mask_chk)
      val_mask_d <- svalue(f1_mask_d_chk)
      val_mask_ils <- svalue(f1_mask_ils_chk)
      val_range <- svalue(f1_mask_spb)
      val_range_ils <- svalue(f1_mask_ils_spb)
      val_kit <- svalue(g2_kit_drp)

      if (val_sample %in% unique(.gDataPrep$Sample.File.Name)) {

        # Must come after 'val_sample'.
        val_data <- subset(.gDataPrep, Sample.File.Name == val_sample)

        if (debug) {
          print("Read Values:")
          print("val_data")
          print(head(val_data))
          print("val_sample")
          print(val_sample)
          print("val_mask_h")
          print(val_mask_h)
          print("val_mask")
          print(val_mask)
          print("val_range")
          print(val_range)
          print("val_mask_d")
          print(val_mask_d)
          print("val_mask_ils")
          print(val_mask_ils)
          print("val_range_ils")
          print(val_range_ils)
          print("val_kit")
          print(val_kit)
        }

        # Get all dyes.
        dyes <- as.character(unique(val_data$Dye))
        colorsKit <- unique(getKit(val_kit, what = "Color")$Color)
        dyesKit <- addColor(colorsKit, have = "Color", need = "Dye")
        dyeILS <- setdiff(dyes, dyesKit)

        # Refactor and keep order of levels.
        val_data$Dye <- factor(val_data$Dye, levels = unique(val_data$Dye))

        # Create plot.
        gp <- ggplot(data = val_data)
        gp <- gp + ggtitle(paste("Masked data for", val_sample))
        gp <- gp + facet_wrap(~Dye, ncol = 1, scales = "fixed", drop = FALSE)
        if (any(val_mask, val_mask_h, val_mask_ils, val_mask_d)) {
          # Change shape, color, and legend.
          gp <- gp + geom_point(aes_string(
            x = "Data.Point", y = "Height",
            colour = "Masked", shape = "Masked"
          ))
          gp <- gp + scale_shape_discrete(
            name = "Peaks",
            breaks = c(FALSE, TRUE),
            labels = c("Included", "Excluded")
          )
          gp <- gp + scale_colour_manual(
            values = c("black", "red"),
            name = "Peaks",
            breaks = c(FALSE, TRUE),
            labels = c("Included", "Excluded")
          )
        } else {
          # Use default color and shape.
          gp <- gp + geom_point(aes_string(x = "Data.Point", y = "Height"))
        }

        if (val_mask_ils) {

          # ILS masking data frame for plot:
          dfIls <- val_data[val_data$ILS == TRUE, ]
          ilsDye <- unique(dfIls$Dye)
          dpMask <- dfIls$Data.Point
          dyeMask <- rep(unique(val_data$Dye), each = length(dpMask))
          dpMask <- rep(dpMask, length(unique(val_data$Dye)))
          dfMask <- data.frame(
            Dye = dyeMask, Data.Point = dpMask,
            Xmin = dpMask - val_range_ils,
            Xmax = dpMask + val_range_ils
          )

          if (nrow(dfMask) > 0) {

            # Add masking range to plot.
            gp <- gp + geom_rect(
              data = dfMask,
              aes_string(
                ymin = -Inf, ymax = Inf,
                xmin = "Xmin", xmax = "Xmax"
              ),
              alpha = 0.2,
              fill = addColor(ilsDye, have = "Dye", need = "Color")
            )
          }
        }

        if (val_mask) {
          # Sample masking data frame for plot:
          dfSample <- val_data[!is.na(val_data$Min), ]

          if (val_mask_d) {

            # Loop over dyes and add mask ranges.
            for (d in seq(along = dyesKit)) {

              # Get data points for selected sample.
              dpMask <- dfSample$Data.Point[dfSample$Dye == dyesKit[d]]
              dpMin <- dfSample$Min[dfSample$Dye == dyesKit[d]]
              dpMax <- dfSample$Max[dfSample$Dye == dyesKit[d]]

              # Create mask data.frame.
              dyeMask <- rep(dyesKit[d], length(dpMask))
              dfMask <- data.frame(
                Dye = dyeMask, Data.Point = dpMask,
                Xmin = dpMin, Xmax = dpMax
              )

              if (nrow(dfMask) > 0) {

                # Add masking range to plot.
                gp <- gp + geom_rect(
                  data = dfMask,
                  aes_string(
                    ymin = -Inf, ymax = Inf,
                    xmin = "Xmin", xmax = "Xmax"
                  ),
                  alpha = 0.2, fill = colorsKit[d]
                )
              }
            }
          } else {

            # Get data points for selected sample.
            dpMask <- dfSample$Data.Point
            dpMin <- dfSample$Min
            dpMax <- dfSample$Max

            # Create mask data.frame.
            dyeMask <- rep(dyesKit, each = length(dpMask))
            dpMask <- rep(dpMask, length(dyesKit))
            dpMin <- rep(dpMin, length(dyesKit))
            dpMax <- rep(dpMax, length(dyesKit))
            dfMask <- data.frame(
              Dye = dyeMask, Data.Point = dpMask,
              Xmin = dpMin, Xmax = dpMax
            )

            if (nrow(dfMask) > 0) {

              # Add masking range to plot.
              gp <- gp + geom_rect(
                data = dfMask,
                aes_string(
                  ymin = -Inf, ymax = Inf,
                  xmin = "Xmin", xmax = "Xmax"
                ),
                alpha = 0.2, fill = "red"
              )
            }
          }
        }

        # Show plot.
        print(gp)

        # Save plot object.
        .gPlot <<- gp
      } # End 'sample exist' if.
    } # End 'data exist' if.
  })

  addHandlerChanged(save_btn, handler = function(h, ...) {

    # Get sample name.
    val_name <- svalue(f3_sample_drp)

    if (!is.null(.gPlot)) {

      # Save data.
      ggsave_gui(
        ggplot = .gPlot, name = val_name, parent = w, env = env,
        savegui = savegui, debug = debug
      )
    } else {
      gmessage(
        msg = strMsgPlot,
        title = strMsgTitlePlot,
        icon = "info", parent = w
      )
    }
  })


  # FRAME 4 ###################################################################

  f4 <- gframe(
    text = strFrmSave,
    horizontal = FALSE,
    spacing = 1,
    container = gv
  )

  glabel(text = strLblSave, anchor = c(-1, 0), container = f4)

  f4_save1_edt <- gedit(text = "", container = f4, expand = TRUE)

  glabel(text = strLblSaveRank, anchor = c(-1, 0), container = f4)

  f4_save2_edt <- gedit(text = "", container = f4, expand = TRUE)

  glabel(text = strLblSaveMasked, anchor = c(-1, 0), container = f4)

  f4_save3_edt <- gedit(text = "", container = f4, expand = TRUE)


  # BUTTON ####################################################################

  calculate_btn <- gbutton(text = strBtnCalculate, container = gv)

  addHandlerClicked(calculate_btn, handler = function(h, ...) {

    # Get values.
    if (is.null(.gDataPrep)) {
      val_data <- .gData
    } else {
      val_data <- .gDataPrep
    }
    val_ref <- .gRef
    val_name_data <- svalue(g0_data_drp)
    val_name_ref <- svalue(g1_ref_drp)
    val_ignore <- svalue(f1_ignore_chk)
    val_word <- svalue(f1_word_chk)
    val_mask_h <- svalue(f1_mask_h_chk)
    val_mask <- svalue(f1_mask_chk)
    val_mask_d <- svalue(f1_mask_d_chk)
    val_mask_ils <- svalue(f1_mask_ils_chk)
    val_height <- as.numeric(svalue(f1_mask_h_edt))
    val_range <- svalue(f1_mask_spb)
    val_range_ils <- svalue(f1_mask_ils_spb)
    val_k <- svalue(f1_k_spb)
    val_t <- svalue(f1_t_spb)
    val_a <- svalue(f1_a_spb)
    val_name1 <- svalue(f4_save1_edt)
    val_name2 <- svalue(f4_save2_edt)
    val_name3 <- svalue(f4_save3_edt)

    if (debug) {
      print("Read Values:")
      print("val_data")
      print(head(val_data))
      print("val_ref")
      print(head(val_ref))
      print("val_ignore")
      print(val_ignore)
      print("val_word")
      print(val_word)
      print("val_mask_h")
      print(val_mask_h)
      print("val_height")
      print(val_height)
      print("val_mask")
      print(val_mask)
      print("val_range")
      print(val_range)
      print("val_mask_d")
      print(val_mask_d)
      print("val_mask_ils")
      print(val_mask_ils)
      print("val_range_ils")
      print(val_range_ils)
      print("val_k")
      print(val_k)
      print("val_t")
      print(val_t)
      print("val_a")
      print(val_a)
      print("val_name1")
      print(val_name1)
      print("val_name2")
      print(val_name2)
    }

    # Check if data.
    if (!is.null(val_data)) {

      # Change button.
      blockHandlers(calculate_btn)
      svalue(calculate_btn) <- strBtnProcessing
      unblockHandlers(calculate_btn)
      enabled(calculate_btn) <- FALSE

      datanew <- calculateAT(
        data = val_data,
        ref = val_ref,
        mask.height = val_mask_h,
        height = val_height,
        mask.sample = val_mask,
        per.dye = val_mask_d,
        range.sample = val_range,
        mask.ils = val_mask_ils,
        range.ils = val_range_ils,
        k = val_k,
        rank.t = val_t,
        alpha = val_a,
        ignore.case = val_ignore,
        word = val_word,
        debug = debug
      )


      # Create key-value pairs to log.
      keys <- list(
        "data", "ref", "k", "rank.t", "alpha",
        "mask.height", "height", "mask", "range.sample",
        "mask.ils", "range.ils", "per.dye", "ignore.case",
        "word"
      )

      values <- list(
        val_name_data, val_name_ref, val_k, val_t,
        val_a, val_mask_h, val_height, val_mask, val_range,
        val_mask_ils, val_range_ils, val_mask_d, val_ignore,
        val_word
      )

      # Update audit trail.
      datanew[[1]] <- auditTrail(
        obj = datanew[[1]], key = keys, value = values,
        label = fnc, arguments = FALSE,
        package = "strvalidator"
      )

      datanew[[2]] <- auditTrail(
        obj = datanew[[2]], key = keys, value = values,
        label = fnc, arguments = FALSE,
        package = "strvalidator"
      )

      datanew[[3]] <- auditTrail(
        obj = datanew[[3]], key = keys, value = values,
        label = fnc, arguments = FALSE,
        package = "strvalidator"
      )

      # Save data.
      saveObject(name = val_name1, object = datanew[[1]], parent = w, env = env)
      saveObject(name = val_name2, object = datanew[[2]], parent = w, env = env)
      saveObject(name = val_name3, object = datanew[[3]], parent = w, env = env)

      if (debug) {
        print(str(datanew))
        print(head(datanew))
        print(paste("EXIT:", fnc))
      }

      # Close GUI.
      .saveSettings()
      dispose(w)
    } else {
      message <- strMsgDataset

      gmessage(message,
        title = strMsgTitleDataset,
        icon = "error",
        parent = w
      )
    }
  })

  # INTERNAL FUNCTIONS ########################################################

  .refresh_sample_drp <- function() {

    # Get data frames in global workspace.
    samples <- unique(.gData$Sample.File.Name)

    if (!is.null(samples)) {

      # Populate drop list.
      f3_sample_drp[] <- c(strDrpDefault2, samples)
      svalue(f3_sample_drp, index = TRUE) <- 1
    } else {

      # Populate drop list.
      f3_sample_drp[] <- c(strDrpDefault2)
      svalue(f3_sample_drp, index = TRUE) <- 1
    }
  }

  .refresh_options <- function() {
    val_mask_h <- svalue(f1_mask_h_chk)
    val_mask <- svalue(f1_mask_chk)
    val_mask_d <- svalue(f1_mask_d_chk)
    val_mask_ils <- svalue(f1_mask_ils_chk)

    # Update dependent widgets.
    if (val_mask_h) {
      enabled(f1_mask_h_edt) <- TRUE
    } else {
      enabled(f1_mask_h_edt) <- FALSE
    }

    # Update dependent widgets.
    if (val_mask) {
      enabled(f1_mask_d_chk) <- TRUE
      enabled(f1_mask_spb) <- TRUE
    } else {
      enabled(f1_mask_d_chk) <- FALSE
      enabled(f1_mask_spb) <- FALSE
    }

    # Update dependent widgets.
    if (val_mask_ils) {
      enabled(f1_mask_ils_spb) <- TRUE
    } else {
      enabled(f1_mask_ils_spb) <- FALSE
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
      if (exists(".strvalidator_calculateAT_gui_savegui", envir = env, inherits = FALSE)) {
        svalue(savegui_chk) <- get(".strvalidator_calculateAT_gui_savegui", envir = env)
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
      if (exists(".strvalidator_calculateAT_gui_mask_h", envir = env, inherits = FALSE)) {
        svalue(f1_mask_h_chk) <- get(".strvalidator_calculateAT_gui_mask_h", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_mask", envir = env, inherits = FALSE)) {
        svalue(f1_mask_chk) <- get(".strvalidator_calculateAT_gui_mask", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_mask_ils", envir = env, inherits = FALSE)) {
        svalue(f1_mask_ils_chk) <- get(".strvalidator_calculateAT_gui_mask_ils", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_dye", envir = env, inherits = FALSE)) {
        svalue(f1_mask_d_chk) <- get(".strvalidator_calculateAT_gui_dye", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_height", envir = env, inherits = FALSE)) {
        svalue(f1_mask_h_edt) <- get(".strvalidator_calculateAT_gui_height", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_range", envir = env, inherits = FALSE)) {
        svalue(f1_mask_spb) <- get(".strvalidator_calculateAT_gui_range", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_range_ils", envir = env, inherits = FALSE)) {
        svalue(f1_mask_ils_spb) <- get(".strvalidator_calculateAT_gui_range_ils", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_k", envir = env, inherits = FALSE)) {
        svalue(f1_k_spb) <- get(".strvalidator_calculateAT_gui_k", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_t", envir = env, inherits = FALSE)) {
        svalue(f1_t_spb) <- get(".strvalidator_calculateAT_gui_t", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_a", envir = env, inherits = FALSE)) {
        svalue(f1_a_spb) <- get(".strvalidator_calculateAT_gui_a", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_ignore", envir = env, inherits = FALSE)) {
        svalue(f1_ignore_chk) <- get(".strvalidator_calculateAT_gui_ignore", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_word", envir = env, inherits = FALSE)) {
        svalue(f1_word_chk) <- get(".strvalidator_calculateAT_gui_word", envir = env)
      }
      if (debug) {
        print("Saved settings loaded!")
      }
    }
  }

  .saveSettings <- function() {

    # Then save settings if true.
    if (svalue(savegui_chk)) {
      assign(x = ".strvalidator_calculateAT_gui_savegui", value = svalue(savegui_chk), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_mask_h", value = svalue(f1_mask_h_chk), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_mask", value = svalue(f1_mask_chk), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_mask_ils", value = svalue(f1_mask_ils_chk), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_dye", value = svalue(f1_mask_d_chk), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_height", value = svalue(f1_mask_h_edt), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_range", value = svalue(f1_mask_spb), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_range_ils", value = svalue(f1_mask_ils_spb), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_k", value = svalue(f1_k_spb), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_t", value = svalue(f1_t_spb), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_a", value = svalue(f1_a_spb), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_ignore", value = svalue(f1_ignore_chk), envir = env)
      assign(x = ".strvalidator_calculateAT_gui_word", value = svalue(f1_word_chk), envir = env)
    } else { # or remove all saved values if false.

      if (exists(".strvalidator_calculateAT_gui_savegui", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_savegui", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_mask_h", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_mask_h", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_mask", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_mask", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_mask_ils", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_mask_ils", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_dye", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_dye", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_height", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_height", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_range", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_range", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_range_ils", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_range_ils", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_k", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_k", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_t", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_t", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_a", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_a", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_ignore", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_ignore", envir = env)
      }
      if (exists(".strvalidator_calculateAT_gui_word", envir = env, inherits = FALSE)) {
        remove(".strvalidator_calculateAT_gui_word", envir = env)
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

  # Update otions.
  .refresh_options()

  # Show GUI.
  visible(w) <- TRUE
  focus(w)
}
