function contains_excluded 
    set excluded (echo $argv[1] | tr -d '[]' | tr -d '"' | string split ',')
    set file_name_path $argv[2]

    set file_name (basename $file_name_path)


    for string in $excluded
        set replaced_string (string replace -a "'" "" $string)                
        if test "$replaced_string" = "$file_name"
            echo 1
        end
    end

    return 98

end


function recursive_cleanup
    set directory $argv[1]
    set days_inactive $argv[2]
    set confirm $argv[3]
    set excluded $argv[4]

   


    if test -d $directory
        for file in (find $directory -type f -atime +$days_inactive)
            set ret_val (contains_excluded $excluded $file)
            if test "$ret_val" = "1"
                echo "=========================================================="
                echo "SKIPPING FILE $file BECAUSE OF EXCLUDED EXTENSION"
                echo "=========================================================="
            else
	    if test "$confirm" = "false"
		 rm "$file"
                echo "Deleted $file"
	    else
		echo "Do you want to delete $file? (yes/no or exit to stop the script)"
            
		set choice (read)
                   # IF FILE IN FILES THEN SKIP, ELSE RM
                   if test "$choice" = "yes"
                       rm "$file"
                      echo "Deleted $file"
                   else if test "$choice" = "no"
                       echo "Skipped $file"
                   else if test "$choice" = "exit"
                       echo "Exiting script"
                       return
                   else
                       echo "Unknown option [$choice]. Skipping file [$file] deletion..."
                   end
                end
	    end
        end

        # Recursive call for subdirectories
        # The -type d means that we are searching for direcories
        # The -mindepth 1 ensures that the search will start from depth 1 and not the initial directory.
       
        for subdir in (find $directory -mindepth 1 -type d)
            # IF SUBDIR IN FILES THEN SKIP, ELSE CONTINUE
	    recursive_cleanup $subdir $days_inactive $confirm $excluded
        end
   else
        echo "Directory does not exist."
    end
end

#Function for printing files information
function print_file_info
    set timestamp (stat -c %X $argv[1])
    echo "Date accessed: ("(date -d @$timestamp)") | File path: [$argv[1]] | Size: ["(stat -c %s $argv[1])" bytes]"
end

#Function for the list of strings
function print_list_of_strings
    for string in $argv
        echo " ----> $string"
    end
end


#main function that we call
function cleanup
    set directory $argv[1]
    set days_inactive $argv[2]
    set excluded_files_dirs $argv[5]
    set sort_type $argv[6]
    set confirm $argv[7]
  


   
    if test "$argv[3]" = "true" -o "$argv[3]" = "false"
        set dry_run $argv[3]
    else
        echo "Dry_run argument [3rd argmument] must be 'true' or 'false'."
        return
    end

    if test "$argv[4]" = "true" -o "$argv[4]" = "false"
        set recursive $argv[4]
    else
        echo "Recursive argument [4th argmument] must be 'true' or 'false'."
        return
    end
   
    echo "-----------------------------------------------------------"
    echo "Excluding the following directories and/or file extensions:"
    print_list_of_strings $excluded_files_dirs
    echo "-----------------------------------------------------------"



     # Check if the directory exists
     if test -d $directory

            # Find files not accessed for more than specified days_inactive
	    for file in (find $directory -type f -atime +$days_inactive)
                  print_file_info $file             
              
	    end | 
	    if test  "$sort_type"  =  "asc"
                sort -k2,2n
            else 
                sort -k2,2rn 
            end 
        else
            echo "Directory does not exist."
    end

    if test "$dry_run" = "true"
      echo "I could delete these files but I'm in dryrun mode"
    end




if test "$recursive" = "true" -a "$dry_run" = "false"
        echo "_______________________________________________________"
        echo "     PERFORMING DIRECTORY [$directory] CLEANUP         "
        echo "_______________________________________________________"    
	recursive_cleanup $directory $days_inactive $confirm $excluded_files_dirs
    end

if test "$recursive" = "false" -a "$dry_run" = "false"
        echo "Recursive and dry run are both false. Nothing to do..."
        return
    end


end
