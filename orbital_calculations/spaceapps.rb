#!/usr/bin/env ruby

@ionEngine = {
  :thrust_N => 1.0,
  :power_kW => 50.0,
  :eff_pct => 70.0,
  :Isp_s => 5000.0,
  :Ve_km_s => 50.0
}

@power_per_kg_solar_at_1AU = FIXME

def massFull(mass_empty, mass_propellant)
  return mass_empty + mass_propellant
end

def massEmpty(mass_solar_array, mass_engines, mass_fuel_tank, mass_other)
  return mass_solar_array + mass_engines + mass_fuel_tank + mass_other
end

def massSolarArray(total_power_required, power_per_kg)
  return power_per_kg / total_power_required
end

# deltaV_km_s = Isp * g * ln ( (mass_asteroid_start_kg)) / mass_asteroid_end_kg)
# (mass_asteroid_start_kg) / mass_asteroid_end_kg = e ^ (deltaV_km_s / (Isp * g)
# mass_asteroid_end_kg = mass_asteroid_start_kg / (e ^ (deltaV_km_s / (Isp * g)))
def massAsteroidEnd(deltaV_km_s, Isp, mass_asteroid_start_kg)
  return mass_asteroid_start_kg / (Math::E ** (deltaV_km_s / (Isp * 9.8)))
end

def timeOfJourney(FIXME)
end



# Things we know: deltaV_km_s, mass_asteroid_kg, engine_type, engine_count
# Things we want to know: time to achieve deltaV_km_s, end mass of asteroid

# Givens
deltaV_km_s = 1000
mass_asteroid_start_kg = 2000000

puts "massAsteroidEnd for deltaV #{deltaV_km_s} asteroid mass #{mass_asteroid_kg} is #{massAsteroidEnd(deltaV_km_s, @ionEngine[:Isp_s], mass_asteroid_kg)}"

puts "timeOfJourney for deltaV #{deltaV_km_s} asteroid mass #{mass_asteroid_kg} is #{massAsteroidEnd(deltaV_km_s, @ionEngine[:Isp_s], mass_asteroid_kg)}"
