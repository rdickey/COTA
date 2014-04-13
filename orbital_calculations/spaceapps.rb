#!/usr/bin/env ruby

@engine_type = {
  :ion => {
    :thrust_N => 0.092,
    :power_kW => 2.3,
    :eff_pct => 70.0,
    :isp_s => 3100.0,
    :Ve_km_s => 31.0,
    :mass_kg => 30,  # estimated based on a paper
    :propellant_used_kg_s => 0.00000227777796  # estimated based on http://www.grc.nasa.gov/WWW/ion/past/90s/nstar.htm
  },
  :vasimr => {
    :thrust_N => 5.0,
    :power_kW => 200.0,
    :eff_pct => 50.0,
    :isp_s => 5000.0,
    :Ve_km_s => 50.0,
    :mass_kg => 260,  # estimated based on a paper
    :propellant_used_kg_s => 0.00805152979066  # estimated based on 23d trip with 8t of fuel
  }
}

# http://en.wikipedia.org/wiki/Solar_panels_on_spacecraft
# "Solar arrays producing 300 W/kg and 300 W/m^2 from the sun's 1366 W/m^2 power near the Earth are available."
@power_per_kg_solar_at_1AU_kW = 0.3
@power_per_m2_solar_at_1AU_kW_m2 = 0.3

# spitballing here
@mass_spacecraft_minus_engines_and_array_kg = 5000.0
@power_required_minus_engines_and_fuel_creation_kW = 10.0


# start figuring stuff out

def massSpacecraft(engine_specs, engine_count)
  return massSolarArray(engine_specs, engine_count) + massEngines(engine_specs, engine_count) + @mass_spacecraft_minus_engines_and_array_kg
end

def massSolarArray(engine_specs, engine_count)
  return powerRequiredTotal(engine_specs, engine_count) / @power_per_kg_solar_at_1AU_kW
end

def areaSolarArray(engine_specs, engine_count)
  return powerRequiredTotal(engine_specs, engine_count) / @power_per_m2_solar_at_1AU_kW_m2
end

def massEngines(engine_specs, engine_count)
  return engine_specs[:mass_kg] * engine_count
end

# Need enough power to continually run engines at required power_kW,
# PLUS turning ice into H2 and O2
# PLUS all the extra bullshit
def powerRequiredTotal(engine_specs, engine_count)
  return powerRequiredEngines(engine_specs, engine_count) + powerFuelCreation(engine_specs, engine_count) + @power_required_minus_engines_and_fuel_creation_kW
end

def powerRequiredEngines(engine_specs, engine_count)
  return (engine_specs[:power_kW] * engine_count)
end

# http://www.space.com/51-asteroids-formation-discovery-and-exploration.html
#   "The average temperature of the surface of a typical asteroid is minus 100 degrees F (minus 73 degrees C)"
#   Energy to raise mass of ice to 0C
#   Energy = mass_kg * 1000 (g/kg) * 73K * 2J/g/K = mass_kg * 146000 J/kg
#   Power to raise mass of ice to 0C
#   Power = mass_kg * 146000 K/kg/s
#   Energy to change a mass of ice into water:
#   Energy = mass * Lf = mass_kg * 334000 J/kg
#   Power to raise a mass of ice into water per second
#   Power = mass_kg * 333550 J/kg/s
# Assume 5 kWh/kg efficiency of electrolyser (where 1kg = mass of H2 + O2)
#   1 kWh = 3600000 J, so 18000000 J/kg efficient
#   Energy = mass_kg * 18000000 J/kg
#   Power = mass_kg * 18000000 J/kg/s
# Need to turn propellant_used_kg_s of ice into H2 and O2 every second by melting ice and electrolysing.
# powerFuelCreation = mass_kg * 146000 J/kg/s + mass_kg * 333550 J/kg/s + mass_kg * 18000000 J/kg/s)
#   146000 + 333550 + 18000000 = 18479550  # so... melting ice negligable, electrolysis is everything
# powerFuelCreation = mass_kg * 18479550
def powerFuelCreation(engine_specs, engine_count)
  # may need engine_specs[:propellant_used_kg_s]
  return engine_specs[:propellant_used_kg_s] * 18479550.0
end

# deltaV_km_s = isp * g * ln ( (mass_asteroid_start_kg)) / mass_asteroid_end_kg)
# (mass_asteroid_start_kg) / mass_asteroid_end_kg = e ^ (deltaV_km_s / (isp * g)
# mass_asteroid_end_kg = mass_asteroid_start_kg / (e ^ (deltaV_km_s / (isp * g)))
def massAsteroidEnd(deltaV_km_s, engine_specs, mass_asteroid_start_kg)
  return mass_asteroid_start_kg / (Math::E ** (deltaV_km_s / (engine_specs[:isp_s] * 9.8)))
end

def timeOfJourney(deltaV_km_s, engine_specs, mass_asteroid_start_kg)
  return (@mass_asteroid_start_kg - massAsteroidEnd(@deltaV_km_s, engine_specs, @mass_asteroid_start_kg)) / (engine_specs[:propellant_used_kg_s] * 3600.0 * 24.0)
end



# Things we know: deltaV_km_s, mass_asteroid_start_kg, engine_specs, engine_count
# Things we want to know: time to achieve deltaV_km_s, end mass of asteroid

# Givens
@deltaV_km_s = 1000
@mass_asteroid_start_kg = 2000000
@engine_count = 4

# Now calculate for each type
@engine_type.each do |engine_name, engine_specs|
  puts "For deltaV #{@deltaV_km_s} asteroid mass #{@mass_asteroid_start_kg} and engine name #{engine_name}..."
  puts "  massSolarArray  is  #{(massSolarArray(engine_specs, @engine_count)).round(3).to_s.rjust(12)} kg"
  puts "  areaSolarArray  is  #{(areaSolarArray(engine_specs, @engine_count)).round(3).to_s.rjust(12)} m^2"
  puts "  powerEngines  is  #{(powerRequiredEngines(engine_specs, @engine_count)).round(3).to_s.rjust(12)} kW"
  puts "  powerFuelCreate is  #{(powerFuelCreation(engine_specs, @engine_count)).round(3).to_s.rjust(12)} kW"
  puts "  massSpacecraft  is  #{(massSpacecraft(engine_specs, @engine_count)).round(3).to_s.rjust(12)} kg"
  puts "  massAsteroidEnd is  #{(massAsteroidEnd(@deltaV_km_s, engine_specs, @mass_asteroid_start_kg)).round(3).to_s.rjust(12)} kg"
  puts "  massAsteroidUsed is #{(@mass_asteroid_start_kg - massAsteroidEnd(@deltaV_km_s, engine_specs, @mass_asteroid_start_kg)).round(3).to_s.rjust(12)} kg"
  puts "  timeOfJourney  is   #{(timeOfJourney(@deltaV_km_s, engine_specs, @mass_asteroid_start_kg)).round(3).to_s.rjust(12)} days"
  puts
end
