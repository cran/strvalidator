################################################################################
# TODO LIST
# TODO: ...

################################################################################
# CHANGE LOG
# 18.07.2013: Check before overwrite object.
# 15.07.2013: Added save GUI settings.
# 11.06.2013: Added 'inherits=FALSE' to 'exists'.
# 04.06.2013: Fixed bug in 'missingCol'.
# 24.05.2013: Improved error message for missing columns.
# 17.05.2013: listDataFrames() -> listObjects()
# 09.05.2013: .result removed, added save as group.
# 25.04.2013: First version.

#' @title Filter Profile GUI
#'
#' @description
#' \code{filterProfile_gui} is a GUI simplifying the filtering of typing data.
#'
#' @details All data not matching the reference will be discarded. Useful for
#' filtering stutters and artifacts from raw typing data.
#' @param env environment in wich to search for data frames.
#' @param savegui logical indicating if GUI settings should be saved in the environment.
#' @param debug logical indicating printing debug information.
#' 

filterProfile_gui <- function(env=parent.frame(), savegui=NULL, debug=FALSE){
  
  # Load dependencies.  
  require(gWidgets)
  options(guiToolkit="RGtk2")
  
  .gData <- NULL
  .gDataName <- NULL
  .gRef <- NULL
  
  if(debug){
    print(paste("IN:", match.call()[[1]]))
  }
  
  
  w <- gwindow(title="Filter profile", visible=FALSE)
  
  # Handler for saving GUI state.
  addHandlerDestroy(w, handler = function (h, ...) {
    .saveSettings()
  })

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
      slimmed <- sum(grepl("Allele",names(.gData), fixed=TRUE)) == 1
      
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
        svalue(f2_save_edt) <- ""
        
      } else if (!slimmed) {
        
        message <- paste("The dataset is too fat!\n\n",
                         "There can only be 1 'Allele' column\n",
                         "Slim the dataset in the 'EDIT' tab", sep="")
        
        gmessage(message, title="message",
                 icon = "error",
                 parent = w) 
        
        # Reset components.
        .gData <<- NULL
        svalue(dataset_drp, index=TRUE) <- 1
        svalue(g0_samples_lbl) <- " 0 samples"
        svalue(f2_save_edt) <- ""
        
      } else {

        # Load or change components.
        .gDataName <<- val_obj
        samples <- length(unique(.gData$Sample.Name))
        svalue(g0_samples_lbl) <- paste("", samples, "samples")
        svalue(f2_save_edt) <- paste(.gDataName, "_filter", sep="")
        
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
      slimmed <- sum(grepl("Allele",names(.gRef), fixed=TRUE)) == 1
      
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
        
      } else if (!slimmed) {
        
        message <- paste("The dataset is too fat!\n\n",
                         "There can only be 1 'Allele' column\n",
                         "Slim the dataset in the 'EDIT' tab", sep="")
        
        gmessage(message, title="message",
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

  # FRAME 1 ###################################################################
  
  f1 <- gframe(text = "Options",
               horizontal=FALSE,
               spacing = 5,
               container = gv) 

  f1_savegui_chk <- gcheckbox(text="Save GUI settings",
                              checked=FALSE,
                              container=f1)
  
  f1_add_missing_loci_chk <- gcheckbox(text="Add missing loci",
                                    checked = TRUE,
                                    container = f1)
  
  f1_keep_na_chk <- gcheckbox(text="Keep NA",
                           checked = FALSE,
                           container = f1)
  
  f1_ignore_case_chk <- gcheckbox(text="Ignore case",
                           checked = TRUE,
                           container = f1)

  # FRAME 2 ###################################################################
  
  f2 <- gframe(text = "Save as",
               horizontal=TRUE,
               spacing = 5,
               container = gv) 
  
  glabel(text="Name for result:", container=f2)
  
  f2_save_edt <- gedit(text="", container=f2)

  # BUTTON ####################################################################
  
  
  filter_btn <- gbutton(text="Filter profile",
                        border=TRUE,
                        container=gv)
  
  addHandlerChanged(filter_btn, handler = function(h, ...) {
    
    val_add_missing_loci <- svalue(f1_add_missing_loci_chk)
    val_keep_na <- svalue(f1_keep_na_chk)
    val_ignore_case <- svalue(f1_ignore_case_chk)
    val_name <- svalue(f2_save_edt)
    
    if(!is.null(.gData) & !is.null(.gRef)){
      
      # Change button.
      svalue(filter_btn) <- "Processing..."
      enabled(filter_btn) <- FALSE
  
      datanew <- filterProfile(data=.gData,
                               ref=.gRef,
                               addMissingLoci=val_add_missing_loci,
                               keepNA=val_keep_na,
                               ignoreCase=val_ignore_case)
      
      # Save data.
      saveObject(name=val_name, object=datanew, parent=w, env=env)
      
      if(debug){
        print(datanew)
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
      if(exists(".filterProfile_gui_savegui", envir=env, inherits = FALSE)){
        svalue(f1_savegui_chk) <- get(".filterProfile_gui_savegui", envir=env)
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
      if(exists(".filterProfile_gui_add_loci", envir=env, inherits = FALSE)){
        svalue(f1_add_missing_loci_chk) <- get(".filterProfile_gui_add_loci", envir=env)
      }
      if(exists(".filterProfile_gui_keep_na", envir=env, inherits = FALSE)){
        svalue(f1_keep_na_chk) <- get(".filterProfile_gui_keep_na", envir=env)
      }
      if(exists(".filterProfile_gui_ignore_case", envir=env, inherits = FALSE)){
        svalue(f1_ignore_case_chk) <- get(".filterProfile_gui_ignore_case", envir=env)
      }
      if(debug){
        print("Saved settings loaded!")
      }
    }
    
  }
  
  .saveSettings <- function(){
    
    # Then save settings if true.
    if(svalue(f1_savegui_chk)){
      
      assign(x=".filterProfile_gui_savegui", value=svalue(f1_savegui_chk), envir=env)
      assign(x=".filterProfile_gui_add_loci", value=svalue(f1_add_missing_loci_chk), envir=env)
      assign(x=".filterProfile_gui_keep_na", value=svalue(f1_keep_na_chk), envir=env)
      assign(x=".filterProfile_gui_ignore_case", value=svalue(f1_ignore_case_chk), envir=env)
      
    } else { # or remove all saved values if false.
      
      if(exists(".filterProfile_gui_savegui", envir=env, inherits = FALSE)){
        remove(".filterProfile_gui_savegui", envir = env)
      }
      if(exists(".filterProfile_gui_add_loci", envir=env, inherits = FALSE)){
        remove(".filterProfile_gui_add_loci", envir = env)
      }
      if(exists(".filterProfile_gui_keep_na", envir=env, inherits = FALSE)){
        remove(".filterProfile_gui_keep_na", envir = env)
      }
      if(exists(".filterProfile_gui_ignore_case", envir=env, inherits = FALSE)){
        remove(".filterProfile_gui_ignore_case", envir = env)
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