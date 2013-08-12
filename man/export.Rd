\name{export}
\alias{export}
\title{Export}
\usage{
  export(object, name = NA, useObjectName = is.na(name),
    env = parent.frame(), path = NA, ext = "auto",
    delim = "\t", width = 3000, height = 2000, res = 250,
    overwrite = FALSE, debug = FALSE)
}
\arguments{
  \item{object}{string, list or vector containing object
  names to be exported.}

  \item{name}{string, list or vector containing file names.
  Multiple names as string must be separated by pipe '|'.
  If not equal number of names as objects, first name will
  be used to construct names.}

  \item{useObjectName}{logical, if TRUE file name will be
  the same as object name.}

  \item{env}{environment where the objects exists.}

  \item{path}{string specifying the destination folder
  exported objects.}

  \item{ext}{string specifying file extension. Default is
  'auto' for automatic .txt or .png based on object class.
  If .RData all objects will be exported as .RData files.}

  \item{delim}{string specifying the delimeter used as
  separator.}

  \item{width}{integer specifying the width of the image.}

  \item{height}{integer specifying the height of the
  image.}

  \item{res}{integer specifying the resolution of the
  image.}

  \item{overwrite}{logical, TRUE if existing files should
  be overwritten.}

  \item{debug}{logical indicating printing debug
  information.}
}
\value{
  NA if all objects were exported OR, data.frame with
  columns 'Object', 'Name', and 'New.Name' with objects
  that were not exported.
}
\description{
  \code{export} exports or saves various objects.
}
\details{
  Export objects to a directory on the file system.
  Currently only objects of class data.frames or ggplot are
  supported. data.frame objects will be exported as '.txt'
  and ggplot objects as '.png'. .RData applies to all
  supported object types.
}
\keyword{internal}
