#!/usr/bin/awk -f
# generate ctags for R source
#
# kinds:
#  c class
#  m member 
#  f function
#  v variable 
#  i import 
#  b block 

function new_tag(name, lnum, line,  kind) {
	gsub(/\\/,"\\\\",line)
	gsub(/\//,"\\/",line)
    print name "\t" FILENAME "\t/^" line "$/;\"\t" kind "\tline:" lnum
    #tag[name] = FILENAME "\t/^" line "$/;\"\t" kind "\tline:" lnum
    #print name "\t" tag[name]
}

BEGIN {
    currentfile = "XXXXXXXXXXXXXXXXXXXXXX"
}

# reset line count for each file
FILENAME != currentfile {
    linenum = 0
    currentfile = FILENAME
}

{ 
    linenum = linenum+1
    curline = $0
}

/^#:/ { 
    match($0, /^#:[[:space:]]*(.*)/, a) 
    name = a[1]
	gsub(/[[:space:]]/,"_",name)
    new_tag(name, linenum, curline, "b")
} 

/^#/ { next } #skip comment lines


# functions
/.*<-.*/ {
    
    if ( match($0, /^([_a-zA-Z0-9.]+)\$new[[:space:]]*<-[[:space:]]*function/, a) ) {
        # class$new <- function()   
        new_tag(a[1], linenum,  curline, "c")
        new_tag("new", linenum, curline, "m\tclass:" a[1])
    }else 
    if ( match($0, /^([_a-zA-Z0-9.]+)\$([a-zA-Z0-9_]+)[[:space:]]*<-[[:space:]]*function/, a) ) {
        # class$method <- function()   
        new_tag(a[2], linenum, curline, "m\tclass:" a[1])
    }else
    if ( match($0, /^([_a-zA-Z0-9.]+)[[:space:]]*<-[[:space:]]*function/, a) ) {
        # fname <- function()   
        new_tag(a[1], linenum, curline, "f")
    }else
    if (match($0, /^([_a-zA-Z.][a-zA-Z0-9._]*)[[:space:]]<-/, a )) {
        # varname <- value   
        match($0, /^([_a-zA-Z0-9._]+)[[:space:]]*<-/, a) 
        new_tag(a[1], linenum, curline, "v")
    }
}

# package imports
/(require|library)\(/ {
    if ( match($0, /^(require|library)\(([a-zA-Z0-9.]+)\)/, a) ) {
        new_tag(a[2], linenum, curline, "i")
    }
}

# /setClass\(/ {
#     match($0, /setClass\(["']([a-zA-Z0-9._]+)["']\)/, a)
#     new_tag(a[1], NR, curline, "c")
# 
# }
# 

#END {
#	for (i in tags) {
#		print i "\t" tags[i] 
#	}
#}
