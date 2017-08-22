module ET
  class Subscriber < ET::CUDSupport
    attr_reader :code, :message, :status, :email, :results

    def initialize(client, list_id = nil)
      super()
      @client = client
      @list_id = list_id
      @obj = 'Subscriber'
    end

    def post
      if @props.is_a? Array then
        currentProps = @props.map do |prop|
          {
            'Lists' => { 'ID' => @list_id },
            'SubscriberKey' => prop['EmailAddress'],
            'EmailAddress' => prop['EmailAddress'],
          }
        end
      elsif @props.is_a? Hash
        currentProps = {
          'Lists' => { 'ID' => @list_id },
          'SubscriberKey' => @props['EmailAddress'],
          'EmailAddress' => @props['EmailAddress'],
        }
      end
      postResponse = super(currentProps)
      response = postResponse

      emails = postResponse.results.map do |result|
        result[:object][:email_address] if result[:error_code] == '12014'
      end.compact.uniq
      if emails.any?
        newCurrentProps = currentProps.select {|prop| emails.include? prop['EmailAddress']}
        patchResponse = patch(newCurrentProps)
        response = mergeResponses(postResponse, patchResponse)
      end
      response
    end

    def mergeResponses(postResponse, patchResponse)
      response = postResponse.dup
      postResults = postResponse.results.select do |result|
        result[:status_code] != 'Error'
      end
      patchResults = patchResponse.results.select do |result|
        result[:status_code] != 'Error'
      end

      response.results = postResults | patchResults
      response.status = true
      response
    end

    def find(email)
      @email = email

      props = %w(SubscriberKey EmailAddress Status)
      filter = {
        'Property' => 'SubscriberKey',
        'SimpleOperator' => 'equals',
        'Value' => email
      }

      res = get(props, filter)
      @email = email if assign_values(res)

      self
    end

    def find_by_email(email)
      @email = email
      props = %w(SubscriberKey EmailAddress Status)
      filter = {
        'Property' => 'EmailAddress',
        'SimpleOperator' => 'equals',
        'Value' => email
      }
      res = get(props, filter)
      @email = email if assign_values(res)
      self
    end

    def delete_from_list(list_id, email, subscriber_key)
      params = {
        'Options' => {
          'SaveOptions' => {
            'SaveOption' => {
              'PropertyName' => '*',
              'SaveAction' => 'UpdateAdd'
            }
          }
        },
        'EmailAddress' => email,
        'SubscriberKey' => subscriber_key,
        'Lists' => {
          'ID' => list_id,
          'Action' => 'delete'
        }
      }
      res = post(params)
      assign_values(res)
      self
    end

    private

    def assign_values(res)
      @code = res.code.to_i
      @message = res.message.to_s
      @status = res.status
      @results = res.results

      res.status
    end
  end
end
