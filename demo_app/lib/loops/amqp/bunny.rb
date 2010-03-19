# Configuration options (all)
# Queue connect to (optional, loop's name will be used by default)
#   queue_name: sheeps
# Does we need to ack each message?
#   queue_ack:  true
# Exchange (optional, 'amq.default' will be used by default)
#   exchange: 'amq.default'
# Key used to filter messages
#   key: 'bunny.*'
# Sleep for N seconds if there are no messages
#   noop_sleep: 5
# Timeout execution (disabled by default)
#   action_timeout: 10
# Max execution times (disabled by default)
#   max_requests: 5
# Conection data (optional)
#   connection:
#     host: localhost
#     user: guest
#     pass: guest
#     port: 5672
#     vhost: '/'
#     spec: '08'

class Loops::AMQP::Bunny < Loops::Base
  def self.check_dependencies
    gem 'bunny'
    require 'bunny'
  end

  def run
    create_client
    create_queue
    total_served = 0
    
    100.times do
      if shutdown?
        disconnect_client_and_exit
      end
      
      begin
        msg = @queue.pop(:ack => !!config['queue_ack'])[:payload]
        if msg == :queue_empty
          sleep config['noop_sleep']
          next
        end
        begin
          if config['action_timeout']
            timeout(config['action_timeout']) { process_message(msg) }
          else
            process_message(msg)
          end
        rescue StandardError => e
          error "Exception from process message! We won't be ACKing the message."
          error "Details: #{e} at #{e.backtrace.first}"
          disconnect_client_and_exit
        end
        
        @queue.ack if config['queue_ack']
        total_served += 1
        if config['max_requests'] && total_served >= config['max_requests'].to_i
          disconnect_client_and_exit
        end
      rescue StandardError => e
        error "Closing queue connection because of exception: #{e} at #{e.backtrace.first}"
        disconnect_client_and_exit
      end
      
    end

  end

  def process_message(msg)
    raise "This method process_message(msg) should be overriden in the loop class!"
  end

  private

  def create_client
    @connection = ::Bunny.new(symbolize_keys(config['connection']))
    @connection.start
    setup_signals
  end
  
  def create_queue
    config['queue_name'] ||= "#{name}"
    error "Subscribing for the queue #{config['queue_name']}..."

    @queue = @connection.queue config['queue_name'], :durable => true
    @exchange = @connection.exchange config['exchange'], :type => :topic, :durable => true
    config['key'] ||= config['queue_name']
    @queue.bind(@exchange, :key => config['key'])
  end

  def disconnect_client_and_exit
    debug "Shutting down..."
    @connection.stop rescue nil
    exit(0)
  end

  def setup_signals
    Signal.trap('INT') { disconnect_client_and_exit }
    Signal.trap('TERM') { disconnect_client_and_exit }
  end
  
  def symbolize_keys(hash)
    return hash unless hash.kind_of? Hash
    if hash.respond_to? :symbolize_keys
      hash.symbolize_keys
    else
      hash.inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end
  end
  
end
