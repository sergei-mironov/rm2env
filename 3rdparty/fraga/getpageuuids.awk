BEGIN { 
    FS = "\"";
    pages = 0; 
}
/"pages"/ { 
    pages = 1; 
    #print "found start of pages"
}
/"[0-9a-f]{8}-[0-9a-f]{4}-/ {
    if ( pages ) {
        print $2;
    }
}
/],/ {
    if (pages) {
        pages = 0;
        # print "no longer scanning pages";
    }
}
