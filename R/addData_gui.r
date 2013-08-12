################################################################################
# TODO LIST
# TODO: ...

################################################################################
# CHANGE LOG
# 31.07.2013: Added parameter 'ignoreCase'.
# 18.07.2013: Check before overwrite object.
# 11.07.2013: Added save GUI settings.
# 11.06.2013: Added 'inherits=FALSE' to 'exists'.
# 17.05.2013: listDataFrames() -> listObjects()
# 09.05.2013: .result removed, added save as group.
# 25.04.2013: First version.

#' @title Add data GUI
#'
#' @description
#' \code{addData_gui} is a GUI wrapper for \code{addData}.
#'
#' @details Add new information to a dataset from a second dataset by
#' a key column.
#' @param env environment in wich to search for data frames.
#' @param savegui logical indicating if GUI settings should be saved in the environment.
#' @param debug logical indicating printing debug information.
#' 

addData_gui <- function(env=parent.frame(), savegui=NULL, debug=FALSE){
  
  # Load dependencies.  
  require(gWidgets)
  options(guiToolkit="RGtk2")
  
  # Global variables.
  .gDataDest <- NULL
  .gDataDestName <- NULL
  .gDataDestColumns <- NULL
  .gDataSource <- NULL
  .gDataSourceColumns <- NULL
  .gDefaultDrp <- "<Select column>"
  
  if(debug){
    print(paste("IN:", match.call()[[1]]))
  }
  
  # Main window.  
  w <- gwindow(title="Add data", visible=FALSE)
  
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
  
  g0[1,1] <- glabel(text="Select destination dataset:", container=g0)

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

      .gDataDest <<- get(val_obj, envir=env)
      .gDataDestName <<- val_obj
      .gDataDestColumns <<- names(.gDataDest)
      
      samples <- length(unique(.gDataDest$Sample.Name))
      svalue(g0_samples_lbl) <- paste(" ", samples, "samples")
      svalue(f2_save_edt) <- paste(.gDataDestName, "_new", sep="")
      f1_key_drp[] <- c(.gDefaultDrp,
                        intersect(.gDataDestColumns,.gDataSourceColumns))
      f1_key2_drp[] <- c(.gDefaultDrp,
                        intersect(.gDataDestColumns,.gDataSourceColumns))
      
    } else {
      
      .gDataDest <<- NULL
      svalue(dataset_drp, index=TRUE) <- 1
      svalue(g0_samples_lbl) <- " 0 samples"
      svalue(f2_save_edt) <- ""
      f1_key_drp[] <- .gDefaultDrp
      f1_key2_drp[] <- .gDefaultDrp
    }
  } )  
  
  g0[2,1] <- glabel(text="Select source dataset:", container=g0)
  
  g0[2,2] <- refset_drp <- gdroplist(items=c("<Select dataset>",
                                   listObjects(env=env,
                                               objClass="data.frame")), 
                           selected = 1,
                           editable = FALSE,
                           container = g0) 
  
  g0[2,3] <- g0_ref_lbl <- glabel(text=" 0 samples", container=g0)
  
  addHandlerChanged(refset_drp, handler = function (h, ...) {
    
    val_obj <- svalue(refset_drp)
    
    if(exists(val_obj, envir=env, inherits = FALSE)){
      
      .gDataSource <<- get(val_obj, envir=env)
      .gDataSourceColumns <<- names(.gDataSource)
      ref <- length(unique(.gDataSource$Sample.Name))
      svalue(g0_ref_lbl) <- paste(" ", ref, "samples")
      
      f1_key_drp[] <- c(.gDefaultDrp,
                        intersect(.gDataDestColumns,.gDataSourceColumns))
        
      f1_key2_drp[] <- c(.gDefaultDrp,
                        intersect(.gDataDestColumns,.gDataSourceColumns))
    } else {
      
      .gDataSource <<- NULL
      svalue(refset_drp, index=TRUE) <- 1
      svalue(g0_ref_lbl) <- " 0 samples"
      f1_key_drp[] <- .gDefaultDrp
      f1_key2_drp[] <- .gDefaultDrp
      
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
  
  f1_exact_chk <- gcheckbox(text="Exact key matching",
                                    checked = TRUE,
                                    container = f1)
  
  f1_ignore_chk <- gcheckbox(text="Ignore case",
                            checked = TRUE,
                            container = f1)
  
  enabled(f1_ignore_chk) <- !svalue(f1_exact_chk)
  
  glabel(text="Select key column:", container = f1, anchor=c(-1 ,0))
  f1_key_drp <- gdroplist(items=.gDefaultDrp,
                          selected = 1,
                          editable = FALSE,
                          container = f1)
  
  glabel(text="Select second key column:", container = f1, anchor=c(-1 ,0))
  f1_key2_drp <- gdroplist(items=.gDefaultDrp,
                          selected = 1,
                          editable = FALSE,
                          container = f1)

  addHandlerChanged(f1_exact_chk, handler = function (h, ...) {
    
    val_obj <- svalue(f1_exact_chk)
    
    if(val_obj){
      enabled(f1_ignore_chk) <- FALSE
    } else {
      enabled(f1_ignore_chk) <- TRUE
    }
    
  } )  

  # FRAME 2 ###################################################################
  
  f2 <- gframe(text = "Save as",
               horizontal=TRUE,
               spacing = 5,
               container = gv) 
  
  glabel(text="Name for result:", container=f2)
  
  f2_save_edt <- gedit(text="", container=f2)

  # BUTTON ####################################################################
  
  
  add_btn <- gbutton(text="Add new data",
                        border=TRUE,
                        container=gv)
  
  addHandlerChanged(add_btn, handler = function(h, ...) {
    
    val_exact <- svalue(f1_exact_chk)
    val_key <- svalue(f1_key_drp)
    val_key2 <- svalue(f1_key2_drp)
    val_name <- svalue(f2_save_edt)
    val_ignore <- svalue(f1_ignore_chk)
    
    if(val_key == .gDefaultDrp){
      val_key <- NULL
    }
    if(val_key2 == .gDefaultDrp){
      val_key2 <- NULL
    }
    
    if(debug){
      print("val_exact")
      print(val_exact)
      print("val_key")
      print(val_key)
      print("val_key2")
      print(val_key2)
      print("val_name")
      print(val_name)
      print("val_ignore")
      print(val_ignore)
    }

    # Check dataset and first key (second key is optional)
    if(!is.null(.gDataDest) & !is.null(.gDataSource) & !is.null(val_key)){
      
      # Change button.
      svalue(add_btn) <- "Processing..."
      enabled(add_btn) <- FALSE
  
      datanew <- addData(data=.gDataDest,
                         newData=.gDataSource,
                         exact=val_exact,
                         byCol=val_key,
                         thenByCol=val_key2,
                         ignoreCase=val_ignore)
      
      # Save data.
      saveObject(name=val_name, object=datanew, parent=w, env=env)
      
      if(debug){
        print(datanew)
        print(paste("EXIT:", match.call()[[1]]))
      }
      
      # Close GUI.
      dispose(w)
    
    } else {
      
      message <- "A destination and a source dataset have to be selected."
      
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
      if(exists(".addData_gui_savegui", envir=env, inherits = FALSE)){
        svalue(f1_savegui_chk) <- get(".addData_gui_savegui", envir=env)
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
      if(exists(".addData_gui_exact", envir=env, inherits = FALSE)){
        svalue(f1_exact_chk) <- get(".addData_gui_exact", envir=env)
      }
      if(debug){
        print("Saved settings loaded!")
      }
    }
    
  }
  
  .saveSettings <- function(){
    
    # Then save settings if true.
    if(svalue(f1_savegui_chk)){
      
      assign(x=".addData_gui_savegui", value=svalue(f1_savegui_chk), envir=env)
      assign(x=".addData_gui_exact", value=svalue(f1_exact_chk), envir=env)
      
    } else { # or remove all saved values if false.
      
      if(exists(".addData_gui_savegui", envir=env, inherits = FALSE)){
        remove(".addData_gui_savegui", envir = env)
      }
      if(exists(".addData_gui_exact", envir=env, inherits = FALSE)){
        remove(".addData_gui_exact", envir = env)
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