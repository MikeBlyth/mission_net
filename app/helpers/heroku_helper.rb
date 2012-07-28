module HerokuHelper
  
  # Note that these are not fast requests -- seems like they typically take a few seconds.
  
  def heroku_connection
    Heroku::API.new(:api_key => 'd758366a60299d3bb593d2aae9ae3b7455eacd14')
  end
  
  def heroku_workers(heroku)
    processes = heroku.get_ps('joslink').body
    processes.map {|p| {:process => p['process'], :elapsed => p['elapsed']} if p['process'] =~ /work/i}.compact
  end
  
  def heroku_add_worker(heroku, n=1)
    heroku.post_ps_scale('joslink', 'worker', "+#{n}")
  end

  def heroku_remove_worker(heroku, n=1)
    heroku.post_ps_scale('joslink', 'worker', "-#{n}")
  end

  def heroku_remove_all_workers(heroku)
    heroku.post_ps_scale('joslink', 'worker', "0")
  end
        
end

    
