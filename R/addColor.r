################################################################################
# TODO LIST
# TODO: ...

################################################################################
# CHANGE LOG
# 15.12.2013: Fixed check for 'have' and 'need' when converting vector.
# 27.11.2013: Added option 'overwrite'.
# 04.10.2013: Added some debug information.
# 18.09.2013: Added support for vector conversion.
# 17.09.2013: First version.

#' @title Add color information.
#'
#' @description
#' \code{addColor} add color information 'Color', 'Dye' or 'R Color'.
#'
#' @details
#' Primers in forensic STR typing kits are labelled with a fluorescent
#' dye. The dyes are represented with single letters (Dye) in exported result
#' files or with strings (Color) in 'panels' files.
#' For visualisation in R these R color names is used (R.Color).
#' The function can add new color schemes matched to the existing, or
#' it can convert a vector containing on scheme to another. 
#' 
#' @param data data frame or vector.
#' @param kit string representing the forensic STR kit used.
#' Default is NA, in which case 'have' must contain a valid column.
#' @param have string specifying color column to be matched.
#' Default is NA, in which case color information is derived from 'kit' and added
#' to a column named 'Color'.
#' If 'data' is a vector 'have' must be a single string.
#' @param need string or string vector specifying color columns to be added.
#' Default is NA, in which case all columns will be added.
#' If 'data' is a vector 'need' must be a single string.
#' @param overwrite logical if TRUE and column exist it will be overwritten.
#' @param debug logical indicating printing debug information.
#' 
#' @return data.frame with additional columns for added colors, 
#' or vector with converted values.
#' 
#' @examples
#' # Get marker and colors for ESX17.
#' df <- getKit("ESX17", what="Color")
#' # Add dye color.
#' dfDye <- addColor(data=df, need="Dye")
#' # Add all color alternatives.
#' dfAll <- addColor(data=df)
#' # Convert a dye vector to R colors
#' addColor(data=c("R","G","Y","B"), have="dye", need="r.color")


addColor <- function(data, kit=NA, have=NA, need=NA, overwrite=FALSE, debug=FALSE){
  
  if(debug){
    print(paste("IN:", match.call()[[1]]))
  }
  
  # Names:
  colorSchemes <- toupper(c("Color", "Dye", "R.Color"))

  # Definitions:
  schemeColor <- c("black", "blue", "green", "yellow", "red")
  schemeDye <- c("X", "B", "G", "Y", "R")
  schemeRColor <- c("black", "blue", "green3", "black", "red")
  # Numeric values corresponding to color abreviations:
  # NB! There are 8 colors that can be represented by a single number character, palette():
  # 1="black", 2="red", 3="green3", 4="blue", 5="cyan", 6="magenta", 7="yellow", 8="gray" 
  
  if(debug){
    print("data")
    print(str(data))
    print("kit")
    print(kit)
    print("have")
    print(have)
    print("need")
    print(need)
  }
  
  # Check if overwrite.
  if(overwrite){
    if("R.COLOR" %in% toupper(names(data))){
      message("Column 'R.Color' will be overwritten!")
      data$R.Color <- NULL
    }
    if("COLOR" %in% toupper(names(data))){
      message("Column 'Color' will be overwritten!")
      data$Color <- NULL
    }
    if("DYE" %in% toupper(names(data))){
      message("Column 'Dye' will be overwritten!")
      data$Dye <- NULL
    }
  }
  
  # A vector with factors gives 'FALSE' for is.vector but dim always gives 'NULL'.
  if(is.vector(data) | is.null(dim(data))){
    
    if(debug){
      print("data is vector OR dim is NULL")
    }

    # Add color if not exist and kit is provided.
    if(any(is.na(have)) | any(is.na(need))){

      warning("For vector conversion 'have' and 'need' must be provided!")
      
    } else {

      if(toupper(have) == "COLOR"){
        
        if(toupper(need) == "DYE"){
          data <- schemeDye[match(data, schemeColor)]
        }
        if(toupper(need) == "R.COLOR"){
          data <- schemeRColor[match(data, schemeColor)]
        }
        
      }
      
      if(toupper(have) == "DYE"){
        
        if(toupper(need) == "COLOR"){
          data <- schemeColor[match(data, schemeDye)]
        }
        if(toupper(need) == "R.COLOR"){
          data <- schemeRColor[match(data, schemeDye)]
        }
        
      }
      
      if(toupper(have) == "R.COLOR"){
        
        if(toupper(need) == "COLOR"){
          data <- schemeColor[match(data, schemeRColor)]
        }
        
        if(toupper(need) == "DYE"){
          data <- schemeDye[match(data, schemeRColor)]
        }
        
      }
      
    }
      
  } else if(is.data.frame(data)){
    
    if(debug){
      print("data is data.frame")
    }

    # Add color if not exist and kit is provided.
    if(is.na(have) & !is.na(kit)){
      
      # Check if exist.
      if(!"COLOR" %in% toupper(names(data))){
        
        # Get markers and their color.
        kitInfo <- getKit(kit, what="Color")
        marker <- kitInfo$Marker
        mColor <- kitInfo$Color
        
        if(debug){
          print("marker")
          print(str(marker))
          print("mColor")
          print(str(mColor))
        }
        
        # Loop over all markers.
        for(m in seq(along=marker)){
          
          # Add new column and colors per marker.
          data$Color[data$Marker == marker[m]] <- mColor[m]
          
        }
      }
      
      # Add to have.
      have <- "Color"
      
    }
    
    # Find existing colors and convert to upper case.
    if(is.na(have)){
      have <- toupper(names(data)[toupper(names(data)) %in% colorSchemes])
    } else {
      have <- toupper(have)
    }
    
    # Convert to upper case.
    if(!is.na(need)){
      need <- toupper(need)
    } else {
      need <- colorSchemes
    }
    
    # Check if supported.
    if(!any(need %in% colorSchemes)){
      warning(paste(paste(need, collapse=","), "not supported!"))
    }
    
    count <- 1 
    repeat{
      
      if("COLOR" %in% need){
  
        # Check if exist.
        if("COLOR" %in% toupper(names(data))){
          
          warning("A column 'Color' already exist in data frame!")
          
        } else {
          
          # Convert using Dye.
          if("DYE" %in% have){
            if("DYE" %in% toupper(names(data))){
      
              # Convert dye to color.
              data$Color <- schemeColor[match(data$Dye, schemeDye)]
              
            } else {
              warning("Can't find column 'Dye'!\n'Color' was not added!")
            }
          }
          
          # Convert using R color.
          if("R.COLOR" %in% have){
            if("R.COLOR" %in% toupper(names(data))){
              
              # Convert dye to color.
              data$Color <- schemeColor[match(data$R.Color, schemeRColor)]
              
            } else {
              warning("Can't find column 'R.Color'!\n'Color' was not added!")
            }
          }
        }
    
        # Remove from need.
        need <- need[need != "COLOR"]
        
      }
    
      if("DYE" %in% need){
        
        # Check if exist.
        if("DYE" %in% toupper(names(data))){
          
          warning("A column 'Dye' already exist in data frame!")
          
        } else {
          
          # Convert using Color.
          if("COLOR" %in% have){
            if("COLOR" %in% toupper(names(data))){
              
              # Convert color to dye.
              data$Dye <- schemeDye[match(data$Color, schemeColor)]
              
            } else {
              warning("Can't find column 'Color'!\n'Dye' was not added!")
            }
          }
          
          # Convert using R color.
          if("R.COLOR" %in% have){
            if("R.COLOR" %in% toupper(names(data))){
              
              # Convert R color to dye.
              data$Dye <- schemeDye[match(data$R.Color, schemeRColor)]
              
            } else {
              warning("Can't find column 'R.Color'!\n'Dye' was not added!")
            }
          }
        }
        
        # Remove from need.
        need <- need[need != "DYE"]
        
      }
    
      if("R.COLOR" %in% need){
        
        # Check if exist.
        if("R.COLOR" %in% toupper(names(data))){
          
          warning("A column 'R.Color' already exist in data frame!")
          
        } else {
          
          # Convert using Color.
          if("COLOR" %in% have){
            if("COLOR" %in% toupper(names(data))){
              
              # Convert color to R color.
              data$R.Color <- schemeRColor[match(data$Color, schemeColor)]
              
            } else {
              warning("Can't find column 'Color'!\n'R.Color' was not added!")
            }
          }
          
          # Convert using Dye.
          if("DYE" %in% have){
            if("DYE" %in% toupper(names(data))){
              
              # Convert dye to R color.
              data$R.Color <- schemeRColor[match(data$Dye, schemeDye)]
              
            } else {
              warning("Can't find column 'Dye'! \n'R.Color' was not added!")
            }
          }
        }
        
        # Remove from need.
        need <- need[need != "R.COLOR"]
        
      }
  
      # Exit loop.
      if(length(need) == 0 | count > 1){
        break
      }
       
      # Increase loop counter.
      count <- count + 1 
         
    } # End repeat.
  } else {
    
    warning("Unsupported data type!\n No color was added!")
    
  }
  
  if(debug){
    print("Return")
    print(str(data))
  }
  
  return(data)
  
}
