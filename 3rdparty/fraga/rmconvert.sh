#!/bin/bash
#
# convert a remarkable notebook or annotated PDF document to PDF
# suitable for viewing and/or printing, with colour annotations.  This
# code assumes version 1.7.x of the reMarkable system, the version
# that introduced the ability to move pages around.

# there are two scenarios: the first is a notebook file which consists
# solely of what the user has drawn/written using the stylus.  The
# second is where an existing PDF document has been annotated.  In
# either case, we first process the *.rm files which have the
# drawn/written aspects.  Then, if a PDF file exists, these are
# overlaid on that file.

# this script uses a number of other software components:

# 1. rm2svg.py
# 2. inkscape
# 3. pdfinfo
# 4. pdftk
# 5. gs

# all of these, except the first, are standard packages that can be
# installed on a Debian system easily.  The first is available from
# the author of this script as it has been modified compared with what
# is available on the 'net.

# Eric S Fraga, e.fraga@ucl.ac.uk

# ------------------------------------------------ usage and arguments
# check usage and remember uuid argument
if [ $# -lt 1 ]; then
    echo "Convert reMarkable document to PDF"
    echo "usage: $(basename $0) uuid"
    exit 1
fi
uuid=$1
content="${uuid}.content"
pagedata=${uuid}.pagedata
echo rmconvert: processing $uuid

# ------------------------------------------------ file locations
# location of supporting scripts
remarkable="${HOME}/synced/remarkable"
software="${remarkable}/software"

# where are the templates?
templatesdir="${HOME}/synced/remarkable/templates"

# where to store intermediate files
tmp=$(mktemp -d /tmp/remarkable.XXXXXX)
# echo "Temporary directory: ${tmp}"

# ------------------------------------------------ get document geometry
#
# if there is a PDF document, we use this document to specify the
# geometry of the svg files created from the rm files, including
# taking into account if the original PDF was rotated.

doc=${uuid}.pdf
if [ -f ${doc} ]
then
    echo : PDF file exists
    # figure out desired size of SVG image
    width=$(pdfinfo ${doc} | grep 'Page size:' | awk '{print $3}' | sed -e 's/\..*//')
    height=$(pdfinfo ${doc} | grep 'Page size:' | awk '{print $5}' | sed -e 's/\..*//')
    numberofpdfpages=$(pdfinfo ${doc} | grep 'Pages:' | awk '{print $2}')
    usetemplates="no"
    # echo "width is $width and height is $height"
    # comparing floating point numbers in bash directly is not possible
    if (( $(echo "$height > $width" | bc -l) ))
    then
        rotated="no"
    else
        # echo 'PDF file is rotated'
        rotated="yes"
        swap=$width
        width=$height
        height=$swap
    fi
    # extract all the pages from the PDF document into the base
    # directory, but only if that directory exists
    pdfseparate ${doc} ${tmp}/original-%d.pdf >/dev/null 2>/dev/null
else
    # assume default geometry
    # echo ${doc} does not exist so direct conversion of lines files
    rotate="no"
    width=1404
    height=1872
    usetemplates="yes"
    # read in the templates used by each page in the notebook
    readarray -t templates < ${uuid}.pagedata
fi

# ------------------------------------------------ document
# get information about the document
numberofpages=$(grep pageCount ${content} | sed -e 's/[^0-9]//g')
# echo "$numberofpages pages with width $width and height $height "

# get array of uuids for pages in document
awk -f ${software}/getpageuuids.awk ${content} > ${tmp}/pageuuids
readarray -t pageuuids < ${tmp}/pageuuids
rm ${tmp}/pageuuids

# ------------------------------------------------ process pages
#
# convert each page to an SVG image and then to a PDF version.  These
# PDF pages will be left in ${tmp}/N.pdf

for page in $(seq 1 ${numberofpages})
do
    # echo -e -n "processing ${uuid} page ${page} with uuid ${pageuuids[$page]}      \r" 
    # again, recall 0 index page numbering for tablet
    index=$((page - 1))
    rmpage=${uuid}/${pageuuids[$index]}
    if [ -f ${rmpage}.rm ]
    then
        # echo "converting page ${rmpage}                   "
        rm2svg.py -c -i ${rmpage}.rm --width ${width} --height ${height} \
                  -o ${tmp}/${page}.svg 
        if [ "$usetemplates" == "yes" ]
        then
            # echo Looking for template
            templatesvg="${templatesdir}/${templates[$index]}.svg"
            templatepdf="${templatesdir}/${templates[$index]}.pdf"
            templatepng="${templatesdir}/${templates[$index]}.png"
            #template=$(head --lines=${counter} ${base}.pagedata | tail -1)
            # echo Page ${page} template is ${templates[$page]}
            if [ -f "${templatepdf}" ]
            then
                # echo Using existing PDF template ${templatepdf}
                inkscape ${tmp}/${page}.svg --export-filename=${tmp}/tmp.pdf
                pdftk ${tmp}/tmp.pdf background "${templatepdf}" \
                      output ${tmp}/${page}.pdf
                rm ${tmp}/tmp.pdf
            elif [ -f "${templatesvg}" ]
            then
                # echo Using existing SVG template ${templatesvg} converting to PDF
                inkscape "${templatesvg}" --export-filename="${templatepdf}"
                inkscape ${tmp}/${page}.svg --export-filename=${tmp}/tmp.pdf
                pdftk ${tmp}/tmp.pdf background "${templatepdf}" \
                      output ${tmp}/${page}.pdf
                rm ${tmp}/tmp.pdf
            elif [ -f "${templatepng}" ]
            then
                # echo Using existing PNG template ${templatepng}
                convert -geometry ${width}x${height} \
                        -transparent white \
                        "${templatepng}" \
                        ${tmp}/${page}.svg \
                        -composite ${tmp}/${page}.pdf
            else
                # echo Actual template not found
                inkscape --export-width=${width} --export-height=${height} \
                         --export-area-page \
                         ${tmp}/${page}.svg --export-filename=${tmp}/${page}.pdf
            fi
        else
            echo 'creating PDF from svg image of overlay page in ' ${tmp}/${page}.svg
            inkscape --export-width=${width} --export-height=${height} \
                     --export-area-page \
                     --export-filename=${tmp}/${page}.pdf \
                     ${tmp}/${page}.svg
        fi
        if [ "$rotated" == "yes" ]
        then
            pdf270 --outfile ${tmp} ${tmp}/${page}.pdf 2>/dev/null
            mv ${tmp}/${page}-rotated270.pdf ${tmp}/${page}.pdf
        fi
        rm ${tmp}/${page}.svg
    fi
done
echo ''

# ------------------------------------------------ overlay on PDF
#
if [ -f ${doc} ]
then
    for page in $(seq 1 ${numberofpdfpages})
    do
        if [ -f ${tmp}/original-${page}.pdf ]
        then
            if [ -f ${tmp}/${page}.pdf ]
            then
                echo "Overlaying page ${page} with annotations "
                cp ${tmp}/${page}.pdf tmp.pdf
                pdftk tmp.pdf background ${tmp}/original-${page}.pdf \
                      output ${tmp}/${page}-tmp.pdf
                rm tmp.pdf
                rm ${tmp}/original-${page}.pdf
            else
                mv ${tmp}/original-${page}.pdf ${tmp}/${page}-tmp.pdf
            fi
            # use ghostscript to compress the resulting PDF,
            # especially useful for PDF files that come from Microsoft
            # Word
            #
            # see http://tuxdiary.com/2015/04/07/compress-pdf-files-linux/
            gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
               -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH \
               -sOutputFile=${tmp}/${page}.pdf ${tmp}/${page}-tmp.pdf
            rm ${tmp}/${page}-tmp.pdf
        fi
    done
fi

# finally bring all the pages together
pdfunite $(ls -1v ${tmp}/*.pdf) /tmp/${uuid}_annotated.pdf >/dev/null 2>/dev/null

# delete the temporary directory
rm -rf ${tmp}
