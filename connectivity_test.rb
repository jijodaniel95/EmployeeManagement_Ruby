puts "Script started successfully!"
require_relative 'lib/database_connector'

def run_employee_management_demo
  puts "--- Comprehensive Employee Management Service Demo ---"

  # 1. Connect to the database
  begin
    DatabaseConnector.connect('development') # <--- This call might raise an error
  rescue => e # <--- This catches ANY error from the above line, including Mysql2::Error
    puts "Failed to connect to database: #{e.message}"
    puts "Please ensure your MySQL server is running and database.yml credentials are correct."
    return # <--- !!! This exits the method if connection fails !!!
  end

  # If we reach here, it means DatabaseConnector.connect succeeded
  # and did NOT raise an exception. So, the connection is good.

  # 2. Ensure all tables exist (and all subsequent operations)
  # ... all your demo logic ...
end
run_employee_management_demo