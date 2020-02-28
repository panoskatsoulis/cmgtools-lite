#!/bin/bash

function do_help() {
    printf "Use this to generate a directory named <year> with mca files
Fetches info from the path ./metadata
Usage:
$(basename $0) --year <year> --buildfiles <list-of-files> --md <metadata-dir> [--make-draft]
"
    exit 0
}

while [ ! -z "$1" ]; do
    [ "$1" == "--help" ] && do_help
    [ "$1" == "--buildfiles" ] && { buildfiles=$2; shift 2; continue; }
    [ "$1" == "--year" ] && { year=$2; shift 2; continue; }
    [ "$1" == "--md" ] && { metadata=$2; shift 2; continue; }
    [ "$1" == "--make-draft" ] && { mkdraft=true; shift; continue; }
    echo "Unrecognized cli argument $1"
    exit 1
done


## check args and build env
[ -z "$buildfiles" ] && { echo "Specify the list of files to create"; exit 1; }
[ -z "$year" ] && { echo "specify year using '--year <year>'"; exit 1; }
[ -z "$mkdraft" ] && dirout=$year || { dirout=${year}_draft; rm -rf $dirout; }
mkdir $dirout || { echo "Output dir $dirout failed to be created. Check if it exists already."; exit 1; }


## look up info for labels and colors
function getLabel() {
    smpl=$1
    if echo $smpl | grep "DYJets" > /dev/null; then ret='Label="DY(fakes)"'
    elif echo $smpl | grep "WJets" > /dev/null; then ret='Label="Wj(fakes)"'
    elif echo $smpl | grep "^TT" > /dev/null; then ret='Label="tt(fakes)"'
    elif echo $smpl | grep -i "^t[^t]" > /dev/null; then ret='Label="t(fakes)"'
    elif echo $smpl | grep "WW\|ZZ\|VV\|WZ" > /dev/null; then ret='Label="VV(fakes)"'
    fi
    echo $ret
    return 0
}
# function getColor() {
#     smpl=$1
#     echo $smpl | grep DYJets > /dev/null && ret="FillColor=ROOT.kGray"
#     echo $smpl | grep WJets > /dev/null && ret="FillColor=ROOT.kGray"
#     echo $smpl | grep ^TT > /dev/null && ret="FillColor=ROOT.kGray"
#     echo $smpl | grep -i ^t[^t] > /dev/null && ret="FillColor=ROOT.kGray"
#     echo $smpl | grep "WW\|ZZ\|VV\|WZ" > /dev/null && ret="FillColor=ROOT.kGray"
#     echo $ret
#     return 0
# }


## loop over the files asked to create
cat $buildfiles | while read line; do
    ## check validity of line
    [[ $line =~ ^$ ]] && continue
    [ "$metadata" == "metadata/ioanna" ] && {
	echo $file | grep $year > /dev/null || continue # skip files for diff year
	file=$line # this line is a file	    
	buildfile=$dirout/$(echo $file | sed s@.*mca\-includes/201[678]/@@)
    }
    [ "$metadata" == "metadata/manos" ] && {
	file=$(echo $line | sed -r "s/^([^,]*),.*/\1/")
	buildfile=$dirout/$(echo $file | sed s@.*mca\-includes/YEAR/@@)
    }

    ## create file
    ! [ -z "$buildfile" ] && echo "-----> file: $buildfile" || { echo "buildfile var is empty"; exit 2; }
    where=$(dirname $buildfile)
    ! [ -e $where ] && mkdir -p $where
    touch $buildfile # create file

    ## find source file
    srcfile=$year/$(echo $buildfile | sed "s@$dirout/@@")
    echo "-----> srcfile: $srcfile"

    ## get analysis
    if echo $file | grep 2los > /dev/null; then samples=$metadata/2los_mcfakes.txt
    elif echo $file | grep 3l > /dev/null; then samples=$metadata/3l_mcfakes.txt
    else
	echo "couldn't identify analysis for $file, skipping.."
	continue
    fi

    ## get matching cuts & samples
    cuts=$(echo $line | sed "s/^[^,]*,//; s/,/@/g")
    samples=$(cat $samples | tr '\n' '@')
    oldifs=$IFS && IFS='@'

    ## write file
    echo "## file: $(echo $file | sed s/YEAR/$year/)" >> $buildfile
    echo >> $buildfile
    for cut in $cuts; do
	echo "-----> cut: $cut";
	weight=$(echo $cut | sed -r "s/^(.[^ ]*) .*/\1/")
	echo "## weight: $weight" >> $buildfile

	## get extra info from the src file
	# echo $weight
	weight=$(echo $weight | sed s/\*.*//)
	name=$(grep $weight $srcfile | sed -r "s/^([^:]*):.*/\1/; s/ *$//; s/^#//" | sort -u)
	label=$(grep $weight $srcfile | grep -o "Label=[^,]*" | sed "s/ *$//" | sort -u)
	color=$(grep $weight $srcfile | grep -o "FillColor=[^,]*" | sed "s/ *$//" | sort -u)
	echo $name
	echo $label
	echo $color
	$(echo $label | wc | awk '{if ($1>1) print "true"; else print "false"}') && uselookup=true || uselookup=false

	yearfound=false
	for sample in $samples; do
	    ## go to the samples for the correct year
	    if ! $yearfound; then
		echo $sample | grep $year > /dev/null && yearfound=true
		continue ## in any case go to the next line
	    fi
	    ## skip these lines
	    { [ "$sample" == "----" ] || [[ $sample =~ ^$ ]]; } && continue
	    ## if reach next year break
	    { $yearfound && [[ $sample =~ 201[678] ]]; } && break

	    ## check if the sample is commented out and modify cut
	    [[ $sample =~ ^\#[^\#]* ]] && { # if the sample is commented out, move '#' before line
		sample=$(echo $sample | sed s/^#//)
		name="#$name"
	    }
	    cutmodded=$(echo $cut|sed "s@/YEAR/@/$year/@")
	    # echo $cutmodded

	    ## if label is not unique, get info for label from the look up function
	    $uselookup && label=$(getLabel $sample)

	    ## print the line
	    if echo $cutmodded | grep "; *$" > /dev/null; then
		printf "%-25s:%-30s:%s %s,%s\n" $name $sample $cutmodded $label $color >> $buildfile
	    else
		printf "%-25s:%-30s:%s,%s,%s\n" $name $sample $cutmodded $label $color >> $buildfile
	    fi

	    ## clean '#' for the next use
	    name=$(echo $name | sed s/^#//)
	done
	echo >> $buildfile
    done
    IFS=$oldifs # revert delimeter splitting

#    break
done

exit 0
