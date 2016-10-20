module ET
  class Subscriber < ET::CUDSupport
    attr_reader :code, :message, :status, :email, :results

    def initialize(client, list_id = nil)
      super()
      @client = client
      @list_id = list_id
      @obj = 'Subscriber'
    end

    def create(params = {})
      stringify_keys!(params)

      email = params.delete('email')
      raise('Please provide email') if email.blank?

      list_id = if params['list']
                  params.delete('list').id
                elsif params['list_id']
                  params.delete('list_id')
                elsif @list_id
                  @list_id
                end

      props = { 'EmailAddress' => email }
      props['SubscriberKey'] = if params['SubscriberKey']
                                 params.delete('SubscriberKey')
                               else
                                 email
                               end

      props['Lists'] =  [{ 'ID' => list_id.to_s }] if list_id

      if params.count > 0
        props['Attributes'] = params.map do |k, v|
          { 'Name' => k.to_s, 'Value' => v }
        end
      end

      res = post(props)

      # The subscriber is already on the list
      if !res.status && res.results[0][:error_code] == '12014'
        res = patch(props)
      end

      if assign_values(res)
        @email = email
        @list_id = list_id
      end

      self
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

    def update(params)
      params.merge!('EmailAddress' => @email)
      # TODO: ...
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
