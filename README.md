# OperatingSystems_FishShell
Implement the function `cleanup` in `fish` that cleans up unused files after a specific amount of days of inactivity. The main features are:

1) Recursive directory cleaning flag.
2) Dry-run mode to display the files that would be deleted, without actually deleting them.
3) Exclude certain types of files and directories by name (can be more than one).
4) Sorting the files by either largest to smallest or opposite.
5) Adding a comfirmation prompt before actually deleting.

The function signature would look like:
```fish
function cleanup(target_directory, days_inactive, recursive, dry_run, excluded_files_dirs, sort_type, confirmation)
```

* `recursive`, `dry_run`, `confirmation` are of type `boolean`
* `target_directory` is a string
* `days_inactive` is an integer
* `excluded_files`_dirs is a list or multiple arguments
* `sort_type` is either `asc` or `desc`
