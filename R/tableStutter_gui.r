################################################################################
# TODO LIST
# TODO: ...

################################################################################
# CHANGE LOG
# 18.07.2013: Check before overwrite object.
# 11.06.2013: Added 'inherits=FALSE' to 'exists'.
# 10.06.2013: Fixed save GUI settings. New name sufix.
# 06.06.2013: Added save GUI settings.
# 04.06.2013: Fixed bug in 'missingCol'.
# 29.05.2013: Disabled button and adding "processing..." after press.
# 24.05.2013: Improved error message for missing columns.
# 21.05.2013: Fixed name on save as.
# 17.05.2013: listDataFrames() -> listObjects()
# 09.05.2013: .result removed, added save as group.
# 04.05.2013: First version.


#' @title Guess profile
#'
#' @description
#' \code{tableStutter_gui} is a GUI wrapper for the \code{tableStutter} function.
#'
#' @details
#' Simplifies the use of the \code{tableStutter} function by providing a graphical 
#' user interface to it.
#' 
#' @param env environment in wich to search for data frames.
#' @param savegui logical indicating if GUI settings should be saved in the environment.
#' @param debug logical indicating printing debug information.
#' 

tableStutter_gui <- function(env=parent.frame(), savegui=NULL, debug=FALSE){
  
  # Load dependencies.  
  require(gWidgets)
  options(guiToolkit="RGtk2")
  
  # Global variables.
  .gData <- NULL
  .gDataName <- NULL
  
  if(debug){
    print(paste("IN:", match.call()[[1]]))
  }
  
  # Main window.
  w <- gwindow(title="Make stutter table", visible=FALSE)

  # Handler for saving GUI state.
  addHandlerDestroy(w, handler = function (h, ...) {
    .saveSettings()
  })
  
  # Vertical main group.
  gv <- ggroup(horizontal=FALSE,
               spacing=15,
               use.scrollwindow=FALSE,
               container = w,
               expand=TRUE) 
  
  # FRAME 0 ###################################################################
  
  f0 <- gframe(text="Datasets",
                   horizontal=FALSE,
                   spacing = 10,
                   container = gv) 
  
  f0g0 <- glayout(container = f0, spacing = 1)
  
  f0g0[1,1] <- glabel(text="Select dataset:", container=f0g0)
  
  f0g0[1,2] <- f0g0_dataset_drp <- gdroplist(items=c("<Select dataset>",
                                                     listObjects(env=env,
                                                                 objClass="data.frame")),
                                             selected = 1,
                                             editable = FALSE,
                                             container = f0g0)
  
  f0g0[1,3] <- f0g0_samples_lbl <- glabel(text=" 0 samples",
                                              container=f0g0)
  
  addHandlerChanged(f0g0_dataset_drp, handler = function (h, ...) {
    
    val_obj <- svalue(f0g0_dataset_drp)
    
    if(exists(val_obj, envir=env, inherits = FALSE)){
      
      .gData <<- get(val_obj, envir=env)
      requiredCol <- c("Ratio", "Marker","Allele","Type")
      
      if(!all(requiredCol %in% colnames(.gData))){
        
        missingCol <- requiredCol[!requiredCol %in% colnames(.gData)]
        
        message <- paste("Additional columns required:\n",
                         paste(missingCol, collapse="\n"), sep="")
        
        gmessage(message, title="Data error",
                 icon = "error",
                 parent = w) 

        # Reset components.
        .gData <<- data.frame(No.Data=NA)
        .gDataName <<- NULL
        svalue(f0g0_samples_lbl) <- " 0 samples"
        svalue(f2_save_edt) <- ""
        svalue(f0g0_dataset_drp, index=TRUE) <- 1
        
      } else {

        # Load or change components.
        .gDataName <<- val_obj
        samples <- length(unique(.gData$Sample.Name))
        svalue(f0g0_samples_lbl) <- paste(" ", samples, "samples")
        svalue(f2_save_edt) <- paste(.gDataName,
                                     "_table_",
                                     svalue(f1g1_scope_opt),
                                     sep="")
        
      }
      
    } else {
      
      # Reset components.
      .gData <<- data.frame(No.Data=NA)
      .gDataName <<- NULL
      svalue(f0g0_samples_lbl) <- " 0 samples"
      svalue(f2_save_edt) <- ""
      
    }
  } )
  
  # FRAME 1 ###################################################################
  
  f1 <- gframe(text="Options",
                   horizontal=FALSE,
                   spacing = 20,
                   container = gv) 
  
  f1g1 <- glayout(container = f1, spacing = 5)
  
  f1g1[1,1] <- glabel(text="Calculate quantile", container=f1g1)

  f1g1[1,2] <- f1g1_quant_spb <- gspinbutton(from = 0, to = 1,
                                            by = 0.01, value = 0.95,
                                            container = f1g1)

  f1g1[2,1] <- glabel(text="Summarize by", container=f1g1)
  
  f1g1[3,1] <- f1g1_scope_opt <- gradio(items=c("global","locus","stutter"),
                              selected = 3,
                              horizontal = FALSE,
                              container = f1g1)

  f1_savegui_chk <- gcheckbox(text="Save GUI settings",
                                            checked=FALSE,
                                            container=f1)
  
  addHandlerChanged(f1g1_scope_opt, handler = function (h, ...) {

    svalue(f2_save_edt) <- paste(.gDataName,
                                 "_table_",
                                 svalue(f1g1_scope_opt),
                                 sep="")
    
  })
  
  # FRAME 2 ###################################################################
  
  f2 <- gframe(text = "Save as",
               horizontal=TRUE,
               spacing = 5,
               container = gv) 
  
  glabel(text="Name for result:", container=f2)
  
  f2_save_edt <- gedit(text="", width=45, container=f2)

  # BUTTON ####################################################################

  if(debug){
    print("BUTTON")
  }  
  
  run_btn <- gbutton(text="Summarize",
                      border=TRUE,
                      container=gv)
  
  addHandlerChanged(run_btn, handler = function(h, ...) {
    
    # Get values.
    val_data <- .gData
    val_ratio <- as.numeric(svalue(f1g1_quant_spb))
    val_scope <- svalue(f1g1_scope_opt)
    val_name <- svalue(f2_save_edt)
    
    if (!is.null(.gData)){
      
      # Change button.
      svalue(run_btn) <- "Processing..."
      enabled(run_btn) <- FALSE
      
      datanew <- tableStutter(data=val_data,
                   quant=val_ratio,
                   scope=val_scope)
      
      # Save data.
      saveObject(name=val_name, object=datanew, parent=w, env=env)
      
      if(debug){
        print(datanew)
        print(paste("EXIT:", match.call()[[1]]))
      }
      
      # Close GUI.
      dispose(w)
      
    } else {
      
      gmessage(message="Data frame is NULL!\n\n
               Make sure to select a dataset and a reference set",
               title="Error",
               icon = "error")      
      
    } 
    
  } )
  
  # INTERNAL FUNCTIONS ########################################################
  
  .loadSavedSettings <- function(){

    # Set check state if provided.
    if(!is.null(savegui)){
      svalue(f1_savegui_chk) <- savegui
      enabled(f1_savegui_chk) <- FALSE
      if(debug){
        print("Save GUI status set!")
      }  
    } else {
      # Load save flag.
      if(exists(".tableStutter_gui_savegui", envir=env, inherits = FALSE)){
        svalue(f1_savegui_chk) <- get(".tableStutter_gui_savegui", envir=env)
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
      if(exists(".tableStutter_gui_quant", envir=env, inherits = FALSE)){
        svalue(f1g1_quant_spb) <- get(".tableStutter_gui_quant", envir=env)
      }
      if(exists(".tableStutter_gui_scope", envir=env, inherits = FALSE)){
        svalue(f1g1_scope_opt) <- get(".tableStutter_gui_scope", envir=env)
      }
      if(debug){
        print("Saved settings loaded!")
      }
    }
    
  }
  
  .saveSettings <- function(){

    # Then save settings if true.
    if(svalue(f1_savegui_chk)){
      
      assign(x=".tableStutter_gui_savegui", value=svalue(f1_savegui_chk), envir=env)
      assign(x=".tableStutter_gui_quant", value=svalue(f1g1_quant_spb), envir=env)
      assign(x=".tableStutter_gui_scope", value=svalue(f1g1_scope_opt), envir=env)
      
    } else { # or remove all saved values if false.
      
      if(exists(".tableStutter_gui_savegui", envir=env, inherits = FALSE)){
        remove(".tableStutter_gui_savegui", envir = env)
      }
      if(exists(".tableStutter_gui_quant", envir=env, inherits = FALSE)){
        remove(".tableStutter_gui_quant", envir = env)
      }
      if(exists(".tableStutter_gui_scope", envir=env, inherits = FALSE)){
        remove(".tableStutter_gui_scope", envir = env)
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
  
} # End of GUI