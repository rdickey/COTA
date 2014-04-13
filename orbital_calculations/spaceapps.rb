#!/usr/bin/env ruby

@engine_type = {
  :ion_nstar => {
    :thrust_N => 0.092,
    :power_kW => 2.3,
    :eff_pct => 70.0,
    :isp_s => 3100.0,
    :Ve_km_s => 31.0,
    :mass_kg => 30,  # estimated based on a paper
    :propellant_used_kg_s => 0.000002278,  # estimated based on http://www.grc.nasa.gov/WWW/ion/past/90s/nstar.htm
    :hydrogen_only => true
  },
  :ion_ideal => {
    :thrust_N => 2.5,
    :power_kW => 250.0,
    :eff_pct => 70.0,
    :isp_s => 19000.0,
    :Ve_km_s => 190.0,
    :mass_kg => 500,  # estimated based on a paper
    :propellant_used_kg_s => 1.32e-05,  # estimated based on a pdf
    :hydrogen_only => true
  },
  :vasimr_200kw => {
    :thrust_N => 5.0,
    :power_kW => 200.0,
    :eff_pct => 50.0,
    :isp_s => 5000.0,
    :Ve_km_s => 50.0,
    :mass_kg => 2000,  # estimated based on http://web.mit.edu/mars/Conference_Archives/MarsWeek04_April/Speaker_Documents/VASIMREngine-TimGlover.pdf
    :propellant_used_kg_s => 0.0001,  # estimated
    :hydrogen_only => false
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
# Totals
#   146000 + 333550 = 479550  # so
# powerFuelCreation = mass_kg * 479550
def powerFuelCreation(engine_specs, engine_count)
  # assume 50% power efficiency, so double what we "think" we'll have
  return powerFuelCreationHydrogenOnly(engine_specs, engine_count) if engine_specs[:hydrogen_only] 
  return engine_count * engine_specs[:propellant_used_kg_s] * 479550.0 * 2.0
end

# Need to turn propellant_used_kg_s of ice into H2 and O2 every second by melting ice and electrolysing.
# powerFuelCreation = mass_kg * 146000 J/kg/s + mass_kg * 333550 J/kg/s + mass_kg * 18000000 J/kg/s)
#   146000 + 333550 + 18000000 = 18479550  # so... melting ice negligable, electrolysis is everything
# powerFuelCreation = mass_kg * 18479550
def powerFuelCreationHydrogenOnly(engine_specs, engine_count)
  # Since hydrogen will make up only 1/4 of the mass, we need to 4x the power
  # assume 50% power efficiency, so double what we "think" we'll have
  return engine_count * engine_specs[:propellant_used_kg_s] * 18479550.0 * 4.0 * 2.0
end

# Ideal rocket equation: http://exploration.grc.nasa.gov/education/rocket/rktpow.html
# deltaV_km_s = isp * g * ln ( (mass_asteroid_start_kg)) / mass_asteroid_end_kg)
# (mass_asteroid_start_kg) / mass_asteroid_end_kg = e ^ (deltaV_km_s / (isp * g)
# mass_asteroid_end_kg = mass_asteroid_start_kg / (e ^ (deltaV_km_s / (isp * g)))
def massAsteroidEnd(deltaV_km_s, engine_specs, mass_asteroid_start_kg)
  deltaV_m_s = deltaV_km_s * 1000
  return mass_asteroid_start_kg / (Math::E ** (deltaV_m_s / (engine_specs[:isp_s] * 9.8)))
end

def timeOfJourney(deltaV_km_s, engine_specs, mass_asteroid_start_kg, engine_count)
  # 3600 = secs in an hour
  # 24 = hours in a day
  # need to divide the count in, too
  return (@mass_asteroid_start_kg - massAsteroidEnd(@deltaV_km_s, engine_specs, @mass_asteroid_start_kg)) / (engine_count * engine_specs[:propellant_used_kg_s] * 3600.0 * 24.0)
end



# Things we know: deltaV_km_s, mass_asteroid_start_kg, engine_specs, engine_count
# Things we want to know: time to achieve deltaV_km_s, end mass of asteroid

# Givens
@deltaV_km_s = (ARGV.shift || 10).to_f
@mass_asteroid_start_tonnes = (ARGV.shift || 1000).to_f
@mass_asteroid_start_kg = @mass_asteroid_start_tonnes * 1000.0
@engine_count = (ARGV.empty? ? [1, 4, 16] : ARGV)
@counts_valid = true
(0..(@engine_count.length-1)).each {|i| @engine_count[i] = @engine_count[i].to_f; @counts_valid = false if @engine_count[i] == 0.0; }

if @deltaV_km_s == 0.0 || @mass_asteroid_start_kg == 0.0 || !@counts_valid
  puts "Input: @deltaV_km_s = #{@deltaV_km_s}"
  puts "Input: @mass_asteroid_start_kg = #{@mass_asteroid_start_kg}"
  puts "Input: @engine_count = #{@engine_count}"
  puts "You need to use numbers for the arguments, or no arguments at all to use defaults"
  puts
  puts "Usage:"
  puts "  #{$0} [deltaV_in_km]"
  puts "  #{$0} <deltaV_in_km> [mass_asteroid_start_tonnes]"
  puts "  #{$0} <deltaV_in_km> <mass_asteroid_start_tonnes> [engine_count]"
  puts "  #{$0} <deltaV_in_km> <mass_asteroid_start_tonnes> <engine_count> [engine_count] ..."
  puts
  puts "multiple engine_counts can be provided to make outputting them easier"
  exit
end

# Now calculate for each type
@engine_count.to_a.each do |engine_count|
  @engine_type.each do |engine_name, engine_specs|
    mass_solar_array   = massSolarArray(engine_specs, engine_count).round(1)     # kg
    area_solar_array   = areaSolarArray(engine_specs, engine_count).round(1)     # m^2
    power_solar_array  = powerRequiredTotal(engine_specs, engine_count).round(1)  # kW
    mass_engines       = massEngines(engine_specs, engine_count).round(1)   # kg
    power_engines      = powerRequiredEngines(engine_specs, engine_count).round(1) # kW
    power_fuel_create  = powerFuelCreation(engine_specs, engine_count).round(1) # kW
    mass_spacecraft    = massSpacecraft(engine_specs, engine_count).round(1)     # kg
    mass_asteroid_end  = massAsteroidEnd(@deltaV_km_s, engine_specs, @mass_asteroid_start_kg).round(1)  #kg
    mass_asteroid_used = (@mass_asteroid_start_kg - massAsteroidEnd(@deltaV_km_s, engine_specs, @mass_asteroid_start_kg)).round(1)  # kg
    time_of_journey    = timeOfJourney(@deltaV_km_s, engine_specs, @mass_asteroid_start_kg, engine_count).round(1)  # days
  
    puts "For deltaV #{@deltaV_km_s} km/s asteroid mass #{@mass_asteroid_start_tonnes} tonnes and engine name #{engine_name} count of #{engine_count}..."
    puts "  massSolarArray   is  #{(mass_solar_array).to_s.rjust(12)} kg   or #{(mass_solar_array/1000.0).round(1).to_s.rjust(9)} tonnes"
    puts "  areaSolarArray   is  #{(area_solar_array).to_s.rjust(12)} m^2"
    puts "  powerSolarArray  is  #{(power_solar_array).to_s.rjust(12)} kW"
    puts "  massOfEngines    is  #{(mass_engines.to_s).rjust(12)} kg   or #{(mass_engines/1000).round(1).to_s.rjust(9)} tonnes"
    puts "  powerForEngines  is  #{(power_engines).to_s.rjust(12)} kW"
    puts "  powerFuelCreate  is  #{(power_fuel_create).to_s.rjust(12)} kW"
    puts "  massSpacecraft   is  #{(mass_spacecraft).to_s.rjust(12)} kg   or #{(mass_spacecraft/1000.0).round(1).to_s.rjust(9)} tonnes"
    puts "  massAsteroidEnd  is  #{(mass_asteroid_end).to_s.rjust(12)} kg   or #{(mass_asteroid_end/1000.0).round(1).to_s.rjust(9)} tonnes"
    puts "  massAsteroidUsed is  #{(mass_asteroid_used).to_s.rjust(12)} kg   or #{(mass_asteroid_used/1000.0).round(1).to_s.rjust(9)} tonnes"
    puts "  timeOfJourney    is  #{(time_of_journey).to_s.rjust(12)} days or #{(time_of_journey/30.0).round(1).to_s.rjust(9)} months"
    puts
  end
  puts
end
