require_relative '../lib/database_connector'
require 'date'

class Employee
  attr_accessor :emp_id, :first_name, :last_name, :email, :phone, :hire_date, :dept_id, :role_id
  attr_accessor :dept_name, :role_name # For joined data, populated by find/all methods
  
  def initialize(args={})
   
  end

  private def client
    DatabaseConnector.client
  end

  private def transform_keys_to_sym(row)
    row.transform_keys(&:to_sym)
  end

  def find(id)
    id = id.to_i
    query = "SELECT e.*, d.dept_name, r.role_name FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id LEFT JOIN roles r ON e.role_id = r.role_id WHERE e.emp_id = #{id}"
    result = client.query(query).first
    if result
      attributes = transform_keys_to_sym(result)
      @emp_id = attributes[:emp_id]
      @first_name = attributes[:first_name]
      @last_name = attributes[:last_name]
      @email = attributes[:email]
      @phone = attributes[:phone]
      @hire_date = attributes[:hire_date]
      @dept_id = attributes[:dept_id]
      @role_id = attributes[:role_id]
      @dept_name = attributes[:dept_name]
      @role_name = attributes[:role_name]
      self
    else
      nil
    end
  end
  def to_h
    {
      emp_id: @emp_id,
      first_name: @first_name,
      last_name: @last_name,
      email: @email,
      phone: @phone,
      hire_date: @hire_date.to_s, # Ensure date is always a string for JSON
      dept_id: @dept_id,
      role_id: @role_id,
      dept_name: @dept_name, # Will be nil if not loaded by join
      role_name: @role_name   # Will be nil if not loaded by join
    }.compact # Remove nil values for cleaner JSON output
  end
end