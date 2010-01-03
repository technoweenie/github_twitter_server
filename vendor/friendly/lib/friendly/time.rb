# This class was extracted from the cassandra gem by Evan Weaver
# As such, it is distributed under the terms of the apache license.
# See the APACHE-LICENSE file in the root of this project for more information.
#
class Time
  def self.stamp
    Time.now.stamp
  end
  
  def stamp
    to_i * 1_000_000 + usec
  end
end

