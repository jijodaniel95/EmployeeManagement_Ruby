require 'sinatra'
require_relative 'lib/database_connector'
require 'json'
require 'logger'
require 'rack/contrib'
require_relative 'models/employee'

configure :development do
  require 'sinatra/reloader'
  also_reload 'models/employee.rb'
  also_reload 'lib/*.rb'
  set :show_exceptions, false
end

LOGGER=Logger.new(STDOUT)
LOGGER.level = Logger::INFO
use Rack::PostBodyContentTypeParser

def json_response(status_code, data)
  status status_code
  data.to_json
end
def error_response(status_code, message, details = {})
  LOGGER.warn "Error #{status_code}: #{message} - Details: #{details}"
  json_response(status_code, { error: message, details: details })
end
class RecordNotFound < StandardError; end
class ValidationError < StandardError; end
class ConflictError < StandardError; end
class DatabaseError < StandardError; end # Used to wrap exceptions from the MySQL2 gem.
not_found do
  error_response(404, "Resource not found", { path: request.path_info })
end

# Catches `RecordNotFound` errors, returning a 404.
error RecordNotFound do
  error_response(404, env['sinatra.error'].message)
end

# Catches `ValidationError` errors, returning a 400 Bad Request.
error ValidationError do
  error_response(400, "Validation failed", { reasons: env['sinatra.error'].message })
end

# Catches `ConflictError` errors, returning a 409 Conflict.
error ConflictError do
  error_response(409, env['sinatra.error'].message)
end

# Catches `DatabaseError` errors, returning a 500 Internal Server Error.
error DatabaseError do
  error_response(500, "A database error occurred", { original_message: env['sinatra.error'].message })
end

# A catch-all for any other unexpected errors.
error do
  LOGGER.error "Unhandled error: #{env['sinatra.error'].message}\n#{env['sinatra.error'].backtrace.join("\n")}"
  error_response(500, "An unexpected internal server error occurred.")
end


before do
  # Set the Content-Type header to application/json for all responses.
  content_type :json
  LOGGER.info "Processing request: #{request.request_method} #{request.path_info}"
  begin
    DatabaseConnector.connect('development')
  rescue => e
    LOGGER.fatal "Failed to connect to database at start of request: #{e.message}"
    error_response(500, "Service unavailable: Could not connect to database.")
    halt # Stops further processing of the current request.
  end  
end
after do
  DatabaseConnector.close # Closes the database connection to free up resources.
  LOGGER.info "Request processed: #{request.request_method} #{request.path_info} - Status: #{response.status}"
end

get '/employees/:id' do
  employee = Employee.new
  employee = employee.find(params[:id])
  raise RecordNotFound, "Employee with ID #{params[:id]} not found." unless employee


  json_response(200, employee.to_h) # Returns a 204 No Content status for successful deletion.
rescue Mysql2::Error => e
  raise DatabaseError, e.message
end