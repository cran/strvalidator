################################################################################
# TODO LIST
# TODO: ...

################################################################################
# CHANGE LOG
# 16.01.2014: Adding 'option' for drop-out scoring method.
# 13.11.2013: Removed 'allele' argument in call.
# 07.11.2013: Fixed suggested LDT (as.numeric)
# 27.10.2013: Fixed option 'ignore case' not passed to 'check subset'.
# 19.10.2013: Added support for arguments 'allele' and 'threshold'.
# 26.07.2013: Changed parameter 'fixed' to 'word' for 'checkSubset' function.
# 18.07.2013: Check before overwrite object.
# 11.07.2013: Added save GUI settings.
# 11.06.2013: Added 'inherits=FALSE' to 'exists'.
# 04.06.2013: Fixed bug in 'missingCol'.
# 24.05.2013: Improved error message for missing columns.
# 17.05.2013: listDataFrames() -> listObjects()
# 09.05.2013: First version.

#' @title Calculate Dropout GUI
#'
#' @description
#' \code{calculateDropout_gui} is a GUI wrapper for the \code{calculateDropout}
#'  function.
#'
#' @details Scores dropouts for a dataset.
#' @param env environment in wich to search for data frames and save result.
#' @param savegui logical indicating if GUI settings should be saved in the environment.
#' @param debug logical indicating printing debug information.
#' 

calculateDropout_gui <- function(env=parent.frame(), savegui=NULL,
                                 debug=FALSE){
  
  # Global variables.
  .gData <- NULL
  .gRef <- NULL
  
  if(debug){
    print(paste("IN:", match.call()[[1]]))
  }

  # Main window.
  w <- gwindow(title="Calculate drop-out", visible=FALSE)
  
  # Handler for saving GUI state.
  addHandlerDestroy(w, handler = function (h, ...) {
    .saveSettings()
  })

  # Vertical main group.
  gv <- ggroup(horizontal=FALSE,
               spacing=8,
               use.scrollwindow=FALSE,
               container = w,
               expand=TRUE) 
  
  # FRAME 0 ###################################################################
  
  f0 <- gframe(text = "Datasets",
               horizontal=FALSE,
               spacing = 5,
               container = gv) 
  
  g0 <- glayout(container = f0, spacing = 1)
  
  # Datasets ------------------------------------------------------------------
  
  g0[1,1] <- glabel(text="Select dataset:", container=g0)

  g0[1,2] <- dataset_drp <- gdroplist(items=c("<Select dataset>",
                                   listObjects(env=env,
                                               objClass="data.frame")), 
                           selected = 1,
                           editable = FALSE,
                           container = g0)
  
  g0[1,3] <- g0_samples_lbl <- glabel(text=" 0 samples", container=g0)
  
  addHandlerChanged(dataset_drp, handler = function (h, ...) {
    
    val_obj <- svalue(dataset_drp)
    
    if(exists(val_obj, envir=env, inherits = FALSE)){

      .gData <<- get(val_obj, envir=env)
      requiredCol <- c("Sample.Name", "Marker", "Allele", "Height")
      
      if(!all(requiredCol %in% colnames(.gData))){
  
        missingCol <- requiredCol[!requiredCol %in% colnames(.gData)]

        message <- paste("Additional columns required:\n",
                         paste(missingCol, collapse="\n"), sep="")
        
        gmessage(message, title="Data error",
                 icon = "error",
                 parent = w) 
        
        # Reset components.
        .gData <<- NULL
        svalue(dataset_drp, index=TRUE) <- 1
        svalue(g0_samples_lbl) <- " 0 samples"
        svalue(f1g1_ldt_edt) <- ""
        svalue(f2_save_edt) <- ""
        
      } else {

        # Load or change components.
        samples <- length(unique(.gData$Sample.Name))
        svalue(g0_samples_lbl) <- paste("", samples, "samples")
        svalue(f1g1_ldt_edt) <- min(as.numeric(.gData$Height), na.rm=TRUE)
        svalue(f2_save_edt) <- paste(val_obj, "_dropout", sep="")
        
      }
      
    } else {
      
      # Reset components.
      .gData <<- NULL
      svalue(dataset_drp, index=TRUE) <- 1
      svalue(g0_samples_lbl) <- " 0 samples"
      svalue(f2_save_edt) <- ""
      
    }
  } )  
  
  g0[2,1] <- glabel(text="Select reference dataset:", container=g0)
  
  g0[2,2] <- refset_drp <- gdroplist(items=c("<Select dataset>",
                                   listObjects(env=env,
                                               objClass="data.frame")), 
                           selected = 1,
                           editable = FALSE,
                           container = g0) 
  
  g0[2,3] <- g0_ref_lbl <- glabel(text=" 0 references", container=g0)
  
  addHandlerChanged(refset_drp, handler = function (h, ...) {
    
    val_obj <- svalue(refset_drp)
    
    if(exists(val_obj, envir=env, inherits = FALSE)){
      
      .gRef <<- get(val_obj, envir=env)

      requiredCol <- c("Sample.Name", "Marker", "Allele")
      
      if(!all(requiredCol %in% colnames(.gData))){
        
        missingCol <- requiredCol[!requiredCol %in% colnames(.gRef)]

        message <- paste("Additional columns required:\n",
                         paste(missingCol, collapse="\n"), sep="")
        
        gmessage(message, title="Data error",
                 icon = "error",
                 parent = w) 
      
        # Reset components.
        .gRef <<- NULL
        svalue(refset_drp, index=TRUE) <- 1
        svalue(g0_ref_lbl) <- " 0 references"
        
      } else {

        # Load or change components.
        ref <- length(unique(.gRef$Sample.Name))
        svalue(g0_ref_lbl) <- paste("", ref, "references")
        
      }
      
    } else {
      
      # Reset components.
      .gRef <<- NULL
      svalue(refset_drp, index=TRUE) <- 1
      svalue(g0_ref_lbl) <- " 0 references"
      
    }
    
  } )  

  # CHECK ---------------------------------------------------------------------
  
  if(debug){
    print("CHECK")
  }  
  
  g0[3,2] <- g0_check_btn <- gbutton(text="Check subsetting",
                       border=TRUE,
                       container=g0)
  
  addHandlerChanged(g0_check_btn, handler = function(h, ...) {
    
    # Get values.
    val_data <- .gData
    val_ref <- .gRef
    val_ignore <- svalue(f1_ignore_case_chk)
    
    if (!is.null(.gData) || !is.null(.gRef)){
      
      chksubset_w <- gwindow(title = "Check subsetting",
                             visible = FALSE, name=title,
                             width = NULL, height= NULL, parent=w,
                             handler = NULL, action = NULL)
      
      chksubset_txt <- checkSubset(data=val_data,
                                   ref=val_ref,
                                   console=FALSE,
                                   ignoreCase=val_ignore,
                                   word=FALSE)
      
      gtext (text = chksubset_txt, width = NULL, height = 300, font.attr = NULL, 
             wrap = FALSE, container = chksubset_w)
      
      visible(chksubset_w) <- TRUE
      
    } else {
      
      gmessage(message="Data frame is NULL!\n\n
               Make sure to select a dataset and a reference set",
               title="Error",
               icon = "error")      
      
    } 
    
  } )
  
  
  # FRAME 1 ###################################################################
  
  f1 <- gframe(text = "Options",
               horizontal=FALSE,
               spacing = 5,
               container = gv) 
  
  f1_savegui_chk <- gcheckbox(text="Save GUI settings",
                              checked=FALSE,
                              container=f1)
  
  f1_ignore_case_chk <- gcheckbox(text="Ignore case",
                           checked = TRUE,
                           container = f1)

  f1g1 <- glayout(container = f1)
  
  f1g1[1,1] <- glabel(text="Limit of detection threshold (LDT):",
                      container=f1g1, anchor=c(-1 ,0))
  
  f1g1[1,2] <- f1g1_ldt_edt <- gedit(text = "", width = 6, container = f1g1)
  
  glabel(text="Drop-out scoring method for modelling of drop-out probabilities:",
         container=f1, anchor=c(-1 ,0))
  
  f1_score1_chk <- gcheckbox(text="Score drop-out relative to the low molecular weight allele",
                             checked=TRUE, container=f1)

  f1_score2_chk <- gcheckbox(text="Score drop-out relative to the high molecular weight allele",
                             checked=FALSE, container=f1)
  
  f1_scorex_chk <- gcheckbox(text="Score drop-out relative to a random allele",
                             checked=FALSE, container=f1)

  f1_scorel_chk <- gcheckbox(text="Score drop-out per locus",
                             checked=FALSE, container=f1)
  
  # FRAME 2 ###################################################################
  
  f2 <- gframe(text = "Save as",
               horizontal=TRUE,
               spacing = 5,
               container = gv) 
  
  glabel(text="Name for result:", container=f2)
  
  f2_save_edt <- gedit(text="", container=f2)

  # BUTTON ####################################################################
  
  
  dropout_btn <- gbutton(text="Calculate dropout",
                        border=TRUE,
                        container=gv)
  
  addHandlerChanged(dropout_btn, handler = function(h, ...) {
    
    val_ignore_case <- svalue(f1_ignore_case_chk)
    val_threshold <- as.numeric(svalue(f1g1_ldt_edt))
    val_name <- svalue(f2_save_edt)
    val_method <- vector()
    
    # Get methods:
    if(svalue(f1_score1_chk)){
      val_method <- c(val_method, "1")
    }
    if(svalue(f1_score2_chk)){
      val_method <- c(val_method, "2")
    }
    if(svalue(f1_scorex_chk)){
      val_method <- c(val_method, "X")
    }
    if(svalue(f1_scorel_chk)){
      val_method <- c(val_method, "L")
    }

    if(debug){
      print("GUI options:")
      print("val_ignore_case")
      print(val_ignore_case)
      print("val_threshold")
      print(val_threshold)
      print("val_name")
      print(val_name)
      print("val_method")
      print(val_method)
    }
    
    # No threshold is represented by NULL (not needed).
    if(length(val_threshold) == 0){
      val_threshold <- NULL
    }
    
    if(debug){
      print("Function arguments:")
      print("val_ignore_case")
      print(val_ignore_case)
      print("val_threshold")
      print(val_threshold)
      print("val_name")
      print(val_name)
    }
    
    if(!is.null(.gData) & !is.null(.gRef)){
      
      # Change button.
      svalue(dropout_btn) <- "Processing..."
      enabled(dropout_btn) <- FALSE
  
      datanew <- calculateDropout(data=.gData,
                                  ref=.gRef,
                                  threshold=val_threshold,
                                  method=val_method,
                                  ignoreCase=val_ignore_case,
                                  debug=debug)
      
      # Save data.
      saveObject(name=val_name, object=datanew, parent=w, env=env)
      
      if(debug){
        print(head(datanew))
        print(paste("EXIT:", match.call()[[1]]))
      }
      
      # Close GUI.
      dispose(w)
    
    } else {
      
      message <- "A dataset and a reference dataset have to be selected."
      
      gmessage(message, title="Datasets not selected",
               icon = "error",
               parent = w) 
      
    }
    
  } )

  # INTERNAL FUNCTIONS ########################################################
  
  .loadSavedSettings <- function(){
    
    # First check status of save flag.
    if(!is.null(savegui)){
      svalue(f1_savegui_chk) <- savegui
      enabled(f1_savegui_chk) <- FALSE
      if(debug){
        print("Save GUI status set!")
      }  
    } else {
      # Load save flag.
      if(exists(".strvalidator_calculateDropout_gui_savegui", envir=env, inherits = FALSE)){
        svalue(f1_savegui_chk) <- get(".strvalidator_calculateDropout_gui_savegui", envir=env)
      }
      if(debug){
        print("Save GUI status loaded!")
      }  
    }
    if(debug){
      print(svalue(f1_savegui_chk))
    }  
    
    # Then load settings if true.
    if(svalue(f1_savegui_chk)){
      if(exists(".strvalidator_calculateDropout_gui_ignore", envir=env, inherits = FALSE)){
        svalue(f1_ignore_case_chk) <- get(".strvalidator_calculateDropout_gui_ignore", envir=env)
      }
      if(exists(".strvalidator_calculateDropout_gui_score1", envir=env, inherits = FALSE)){
        svalue(f1_score1_chk) <- get(".strvalidator_calculateDropout_gui_score1", envir=env)
      }
      if(exists(".strvalidator_calculateDropout_gui_score2", envir=env, inherits = FALSE)){
        svalue(f1_score2_chk) <- get(".strvalidator_calculateDropout_gui_score2", envir=env)
      }
      if(exists(".strvalidator_calculateDropout_gui_scorex", envir=env, inherits = FALSE)){
        svalue(f1_scorex_chk) <- get(".strvalidator_calculateDropout_gui_scorex", envir=env)
      }
      if(exists(".strvalidator_calculateDropout_gui_scorel", envir=env, inherits = FALSE)){
        svalue(f1_scorel_chk) <- get(".strvalidator_calculateDropout_gui_scorel", envir=env)
      }
      
      if(debug){
        print("Saved settings loaded!")
      }
    }
    
  }
  
  .saveSettings <- function(){
    
    # Then save settings if true.
    if(svalue(f1_savegui_chk)){
      
      assign(x=".strvalidator_calculateDropout_gui_savegui", value=svalue(f1_savegui_chk), envir=env)
      assign(x=".strvalidator_calculateDropout_gui_ignore", value=svalue(f1_ignore_case_chk), envir=env)
      assign(x=".strvalidator_calculateDropout_gui_score1", value=svalue(f1_score1_chk), envir=env)
      assign(x=".strvalidator_calculateDropout_gui_score2", value=svalue(f1_score2_chk), envir=env)
      assign(x=".strvalidator_calculateDropout_gui_scorex", value=svalue(f1_scorex_chk), envir=env)
      assign(x=".strvalidator_calculateDropout_gui_scorel", value=svalue(f1_scorel_chk), envir=env)
      
    } else { # or remove all saved values if false.
      
      if(exists(".strvalidator_calculateDropout_gui_savegui", envir=env, inherits = FALSE)){
        remove(".strvalidator_calculateDropout_gui_savegui", envir = env)
      }
      if(exists(".strvalidator_calculateDropout_gui_ignore", envir=env, inherits = FALSE)){
        remove(".strvalidator_calculateDropout_gui_ignore", envir = env)
      }
      if(exists(".strvalidator_calculateDropout_gui_score1", envir=env, inherits = FALSE)){
        remove(".strvalidator_calculateDropout_gui_score1", envir = env)
      }
      if(exists(".strvalidator_calculateDropout_gui_score2", envir=env, inherits = FALSE)){
        remove(".strvalidator_calculateDropout_gui_score2", envir = env)
      }
      if(exists(".strvalidator_calculateDropout_gui_scorex", envir=env, inherits = FALSE)){
        remove(".strvalidator_calculateDropout_gui_scorex", envir = env)
      }
      if(exists(".strvalidator_calculateDropout_gui_scorel", envir=env, inherits = FALSE)){
        remove(".strvalidator_calculateDropout_gui_scorel", envir = env)
      }
      
      if(debug){
        print("Settings cleared!")
      }
    }
    
    if(debug){
      print("Settings saved!")
    }
    
  }
  
  # END GUI ###################################################################
  
  # Load GUI settings.
  .loadSavedSettings()
  
  # Show GUI.
  visible(w) <- TRUE
  
}
