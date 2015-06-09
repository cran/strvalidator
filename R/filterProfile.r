################################################################################
# TODO LIST
# TODO: ...

################################################################################
# CHANGE LOG (last 20 changes)
# 09.04.2015: Added option 'invert' to filter peaks NOT in reference.
# 15.12.2014: Changed parameter names to format: lower.case
# 22.01.2014: Fixed bug. add.missing.loci=TRUE now overrides keep.na=FALSE.
# 10.12.2013: Fixed bug returning all NAs when add.missing.loci=TRUE.
# 08.12.2013: Does not discard columns anymore.
# 08.12.2013: Possible to use a 'ref' without 'Sample.Name' i.e. one profile
#             for all samples in 'data'.
# 06.06.2013: Fixed bug in checking for 'fat' data.
# 03.06.2013: Fixed bug discarding NA loci when add.missing.loci=TRUE.
# 28.04.2013: Fixed "NA" bug (NA worked but not "NA").
# 15.04.2013: Option 'ignore.case'.
# 12.04.2013: Options 'keep.na' and 'add.missing.loci' implemented as 'slow' method. 
# 11.04.2013: Fixed bug when more than one reference sample.
# 11.04.2013: Added debug, datachecks and remove NA alleles.
# <11.04.2013: Roxygenized.
# <11.04.2013: filter profile using data in slim format (faster).

#' @title Filter Profile
#'
#' @description
#' Filter peaks from profiles.
#'
#' @details
#' Filters out the peaks matching (or not matching) specified known profiles
#' from typing data containing 'noise' such as stutters.
#' If 'ref' does not contain a 'Sample.Name' column it will be used
#' as reference for all samples in 'data'. The 'invert' option filters out
#' peaks NOT matching the reference (e.g. drop-in peaks).
#' NB! add.missing.loci overrides keep.na.
#' Returns data where allele names match/not match 'ref' allele names.
#' Required columns are: 'Sample.Name', 'Marker', and 'Allele'.
#' 
#' @param data data frame with genotype data in 'slim' format.
#' @param ref data frame with reference profile in 'slim' format.
#' @param keep.na logical. FALSE discards NA alleles.
#'  TRUE keep loci/sample even if no matching allele.
#' @param add.missing.loci logical. TRUE add loci present in ref but not in data.
#' Overrides keep.na=FALSE.   
#' @param ignore.case logical TRUE ignore case.
#' @param invert logical TRUE filter peaks NOT matching the reference.
#' @param debug logical indicating printing debug information.
#' 
# @importFrom plyr rbind.fill
#' 
#' @export
#' 
#' @return data.frame with extracted result.
#' 

filterProfile <- function(data, ref, add.missing.loci=FALSE, keep.na=FALSE,
                          ignore.case=TRUE, invert=FALSE, debug=FALSE){

  if(debug){
    print(paste("IN:", match.call()[[1]]))
    print("data:")
    print(str(data))
    print("ref:")
    print(str(ref))
    print("add.missing.loci:")
    print(add.missing.loci)
    print("keep.na:")
    print(keep.na)
    print("ignore.case:")
    print(ignore.case)
    print("invert:")
    print(invert)
  }

  # CHECK DATA ----------------------------------------------------------------
  
  # Check dataset.
  if(!any(grepl("Sample.Name", names(data)))){
    stop("'data' must contain a column 'Sample.Name'",
         call. = TRUE)
  }
  
  if(!any(grepl("Marker", names(data)))){
    stop("'data' must contain a column 'Marker'",
         call. = TRUE)
  }
  
  if(!any(grepl("Allele", names(data)))){
    stop("'data' must contain a column 'Allele'",
         call. = TRUE)
  }

  # Check reference dataset.
  if(!any(grepl("Sample.Name", names(ref)))){
    message(paste("'ref' does not contain a column 'Sample.Name'!",
                  "\nThe same reference will be used for all samples."))
  }
  if(!any(grepl("Marker", names(ref)))){
    stop("'ref' must contain a column 'Marker'",
         call. = TRUE)
  }
  if(!any(grepl("Allele", names(ref)))){
    stop("'ref' must contain a column 'Allele'",
         call. = TRUE)
  }
  
  # Check if slim format.
  if(sum(grepl("Allele", names(ref))) > 1){
    stop("'ref' must be in 'slim' format",
         call. = TRUE)
  }
  if(sum(grepl("Allele", names(data))) > 1){
    stop("'data' must be in 'slim' format",
         call. = TRUE)
  }

  # PREPARE -------------------------------------------------------------------
  
  # Check if character data.
  if(!is.character(ref$Allele)){
    message("'Allele' must be character. 'ref' converted")
    data$Allele <- as.character(data$Allele)
  }
  if(!is.character(data$Allele)){
    message("'Allele' must be character. 'data' converted")
    data$Allele <- as.character(data$Allele)
  }

  if(add.missing.loci & !keep.na){
    warning("add.missing.loci overrides 'keep.na'. Setting keep.na=TRUE")
    keep.na=TRUE
  }
  
  # SELECT METHOD -------------------------------------------------------------
  
  if(!add.missing.loci & !keep.na & !invert){
    # Fast method cannot be used if add.missingloci/keep.na/invert is TRUE.
  
    # 'FAST' METHOD -----------------------------------------------------------
    # NB! Discards all NA alleles/loci/samples.
    
    if(debug){
      print("'fast' method")
    }

    # Clean NA (both 'false' and true NA).
    naAllele <- length(data$Allele[data$Allele=="NA"])
    if(naAllele > 0){
      data$Allele[data$Allele=="NA"] <- NA
      message(paste(naAllele, "\"NA\" in 'Allele' converted to NA"))
    }
    naAllele <- sum(is.na(data$Allele))
    if(naAllele > 0){
      data <- data[!is.na(data$Allele),]
      message(paste("Removed", naAllele, "rows where Allele=<NA>"))
    }

    # Get reference names.
    if("Sample.Name" %in% names(ref)){
      # Get reference names from reference dataset.
      refSampleNames <- unique(ref$Sample.Name)
    } else {
      # Get reference names from dataset.
      refSampleNames <- unique(data$Sample.Name)
    }
      
    if(debug){
      print("ref samples:")
      print(refSampleNames)
      print("data samples:")
      print(unique(data$Sample.Name))
      flush.console()
    }
    
    # Initiate boolean match vector to FALSE.
    matchingData <- is.na(data$Sample.Name)
    
    # Get reference sample i.e. use one reference for all samples.
    # NB! only used if no 'Sample.Name' column in ref.
    currentRef <- ref
    
    # Loop through all reference samples.
    for(s in seq(along=refSampleNames)){
      
      if("Sample.Name" %in% names(ref)){
        # Get current reference subset.
        currentRef <- ref[ref$Sample.Name==refSampleNames[s],]
      }
      
      # Select current subset.
      if(ignore.case){
        selectedSamples <- grepl(toupper(refSampleNames[s]),
                                 toupper(data$Sample.Name))
      } else {
        selectedSamples <- grepl(refSampleNames[s], data$Sample.Name)
      }
      
      # Get current marker.
      refMarkers <- unique(currentRef$Marker)
      
      # Loop through all markers.
      for(m in seq(along=refMarkers)){
        
        # Get reference alleles.
        refAlleles <- currentRef$Allele[currentRef$Marker==refMarkers[m]]
        
        # Loop through all alleles.
        for(a in seq(along=refAlleles)){
          
          # Get matching alleles in data.
          mM <- data$Marker==refMarkers[m]
          mA <- data$Allele==refAlleles[a]
          currentMatch <- selectedSamples & mM & mA
          
          # 'Concatenate' booleans
          matchingData <- matchingData | currentMatch
          
        }
      }
    }
    
    # Create return data frame.
    resDf <- data[matchingData, ]
      
  } else {
    
    # 'SLOW' METHOD -----------------------------------------------------------
    # NB! Possible to keep NA alleles, add missing loci, and invert.
    
    if(debug){
      print("'slow' method")
    }
    
    # Create an empty data frame to hold the result.
    resDf <- data.frame(t(rep(NA,length(data))))
    # Add column names.
    names(resDf) <- names(data)
    # Remove all NAs
    resDf  <- resDf [-1,]
    
    if(debug){
      print("resDf:")
      print(resDf)
    }

    # Get reference names.
    if("Sample.Name" %in% names(ref)){
      # Get reference names from reference dataset.
      refSampleNames<- unique(ref$Sample.Name)
    } else {
      # Get reference names from dataset.
      refSampleNames<- unique(data$Sample.Name)
    }
      
    # Get reference sample i.e. use one reference for all samples.
    # NB! only used if no 'Sample.Name' column in ref.
    currentRef <- ref
      
    # Loop through all reference samples.
    for(r in seq(along=refSampleNames)){
      
      if("Sample.Name" %in% names(ref)){
        # Get current reference subset.
        currentRef <- ref[ref$Sample.Name==refSampleNames[r],]
      }
      
      # Get current data subset.
      if(ignore.case){
        selectedSamples <- grepl(toupper(refSampleNames[r]),
                                 toupper(data$Sample.Name))
      } else {
        selectedSamples <- grepl(refSampleNames[r], data$Sample.Name)
      }
      currentDataSubset <- data[selectedSamples, ]

      # Get sample names.
      dataSampleNames<- unique(currentDataSubset$Sample.Name)
      
      # Get current marker.
      refMarkers <- unique(currentRef$Marker)
      
      for(s in seq(along=dataSampleNames)){

        # Get current sample
        currentData <- currentDataSubset[currentDataSubset$Sample.Name == dataSampleNames[s], ]

        # Loop through all markers.
        for(m in seq(along=refMarkers)){
          
          # Get reference alleles.
          refAlleles <- currentRef$Allele[currentRef$Marker==refMarkers[m]]

          # Select current marker.
          selection <- currentData$Marker==refMarkers[m]
          tmpDf <- currentData[selection, ]

          # dataAlleles is of length 0 if no matching marker.
          if(nrow(tmpDf) == 0 & add.missing.loci){
            
            # Add missing marker, allele will become NA in rbind.fill.
            tmpDf <- data.frame(Sample.Name=dataSampleNames[s],
                                Marker=refMarkers[m],
                                stringsAsFactors=FALSE)
            
            if(debug){
              print(paste("missing marker added:", refMarkers[m]))
            }
            
          } else {

            # Filter alleles and add to selection.
            if(invert){
              selection <- selection & !currentData$Allele %in% refAlleles
            } else {
              selection <- selection & currentData$Allele %in% refAlleles
            }
            tmpDf <- currentData[selection, ]
            
            # matching is of length 0 if no matching allele.
            if(nrow(tmpDf) == 0 & keep.na){
              
              # Add missing marker, allele will become NA in rbind.fill.
              tmpDf <- data.frame(Sample.Name=dataSampleNames[s],
                                  Marker=refMarkers[m],
                                  stringsAsFactors=FALSE)
              
              if(debug){
                print(paste("NA kept for marker", refMarkers[m]))
              }
              
            }
            
          }
          
          if(debug){
            print("tmpDf:")
            print(tmpDf)
          }
          
          resDf <- plyr::rbind.fill(resDf, tmpDf)
          
        }
        
      }
    }

  }
  
  # RETURN --------------------------------------------------------------------
  
  if(debug){
    print(paste("EXIT:", match.call()[[1]]))
  }
  
	return(resDf)
  
}
