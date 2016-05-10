This structure of SQL files exists to facilitate repeatable
and comparable work on the SQL-based calculation stack.

To make changes to the calculation system, create a new
date-versioned directory under this folder, and update the
SQL scripts therein (adding as necessary) to reflect your
changes.

Use numbering in the file names to order the execution of
the SQL scripts.

Taken together, the scripts in each dated folder should
completely destroy and re-create the calculation stack.

To apply the changes, create a migration and use the
provided `regenerate_calculator` helper as follows:

```ruby
def up
  regenerate_calculator('your-datestamp-here')
end

def down
  regenerate_calculator('previous-datestamp-here')
end  
```

Avoid making changes to previously dated calculator
versions that have been deployed outside the development
environment.

Old calculator versions can be removed from the active
tree in git once they are no longer relevant.
