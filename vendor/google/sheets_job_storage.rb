require 'google/apis/script_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

class SheetsJobStorage
  attr_reader :service

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Job Descriptions Storage Execution API'.freeze
  CLIENT_SECRETS_PATH = File.join(File.dirname(__FILE__),
                                  '.credentials/client_secret.json')
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               'job-store-credentials.yaml')
  SCOPE = 'https://www.googleapis.com/auth/spreadsheets'.freeze
  SHEET_URL = 'https://docs.google.com/spreadsheets/d/11XrIUjGnK5cUMontj4YnTcEtZ5naly3fLPji8EOhv9U/edit#gid=0'.freeze
  SCRIPT_ID = '1j2J0Sza9B-ySkIw4-R9oH_eC54LDDTOdlBQ6jjZNL0tRgTtoja7kz6NZ'.freeze

  def self.save_job(sheet_name, job_data)
    service = SheetsJobStorage.new.service

    request = Google::Apis::ScriptV1::ExecutionRequest.new(
      function: 'storeJobDescription',
      parameters: [SHEET_URL, sheet_name, job_data]
    )

    begin
      response = service.run_script(SCRIPT_ID, request)
      response.error ? error_message(response) : response.response
    rescue Google::Apis::ClientError => e
      # The API encountered a problem before the script started executing.
      puts 'Error calling API!'
    end
  end

  # This doesn't work--returns 500 error with little useful info
  # TODO: make this work?
  def self.get_jobs(sheet_name)
    service = SheetsJobStorage.new.service

    request = Google::Apis::ScriptV1::ExecutionRequest.new(
      function: 'getJobDescriptions',
      parameters: [SHEET_URL, sheet_name]
    )

    begin
      response = service.run_script(SCRIPT_ID, request)
      response.error ? error_message(response) : response.response
    rescue StandardError => e # Google::Apis::ClientError => e
      # The API encountered a problem before the script started executing.
      puts 'Error calling API!'
      puts e.body
    end
  end

  def self.error_message(response)
    error = response.error.details[0]
    msg = "Script error message: #{error['errorMessage']}"

    if error['scriptStackTraceElements']
      # There may not be a stacktrace if the script didn't start executing.
      msg += "\n\nScript error stacktrace:\n"
      error['scriptStackTraceElements'].each do |trace|
        msg += "\t#{trace['function']}: #{trace['lineNumber']}\n"
      end
    end

    msg
  end

  ######### instance methods

  def initialize
    @service = initialize_api
  end

  private

  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store
    )
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
           'resulting code after authorization'
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end

  def initialize_api
    service = Google::Apis::ScriptV1::ScriptService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    service
  end
end


##### TODO: DELETE the following code when done testing

# SHEET_NAME = 'Dice'.freeze
# JOB_DATA = [
#   'Full Stack Web Dev',
#   'Acme Web Development',
#   'Denver',
#   'http://acme.example.com',
#   '1234',
#   '4321',
#   '01-01-2017'
# ].freeze

# SheetsJobStorage.save_job(SHEET_NAME, JOB_DATA)
# jobs = SheetsJobStorage.get_jobs(SHEET_NAME)
# puts jobs