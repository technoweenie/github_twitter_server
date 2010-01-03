Friendly::Memcached.class_eval do
  add_method_tracer :miss, "Friendly::Memcached/miss"
  add_method_tracer :get, "Friendly::Memcached/get"
  add_method_tracer :multiget, "Friendly::Memcached/multiget"
end

