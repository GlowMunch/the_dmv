require './lib/facility'
require './lib/registrant'

RSpec.describe Facility do
  it 'Makes Objects' do
    registrant_1 = Registrant.new('Bruce', 18, true )
    registrant_2 = Registrant.new('Penny', 16 )
    registrant_3 = Registrant.new('Tucker', 15 )
    facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014'})
    facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
    expect(registrant_1).to be_an_instance_of(Registrant)
    expect(facility_1).to be_an_instance_of(Facility)
  end

  it "Can admin written tests only when service is available and reg has permit" do
    registrant_1 = Registrant.new('Bruce', 18, true )
    facility_1 = Facility.new({ name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014'})
    expect(registrant_1.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
    expect(registrant_1.permit?).to eq(true)
    expect(facility_1.administer_written_test(registrant_1)).to eq(false)
    expect(registrant_1.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
    expect(facility_1.services).to eq([])
    expect(facility_1.add_service('Written Test')).to eq(["Written Test"])
    facility_1.administer_written_test(registrant_1)
    expect(registrant_1.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
  end

  it "Can admin written tests based on criteria" do
    registrant_1 = Registrant.new('Bruce', 18, true )
    registrant_2 = Registrant.new('Penny', 16 )
    registrant_3 = Registrant.new('Tucker', 15 )
    facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014'})
    facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
    facility_1.add_service('Written Test')
    facility_1.administer_written_test(registrant_1)
    expect(registrant_2.age).to eq(16)
    expect(registrant_2.permit?).to eq(false)
    #cant admin because of no permit
    expect(facility_1.administer_written_test(registrant_2)).to eq(false)
    registrant_2.earn_permit
    #can admin after earning permit
    expect(facility_1.administer_written_test(registrant_2)).to eq(true)
    expect(registrant_2.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
    expect(registrant_3.age).to eq(15)
    expect(registrant_3.permit?).to eq(false)
    expect(facility_1.administer_written_test(registrant_3)).to eq(false)
    registrant_3.earn_permit
    #unabel to earn permit because of age
    expect(facility_1.administer_written_test(registrant_3)).to eq(false)
    expect(registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
  end
          
  it "can admin road test" do
    registrant_1 = Registrant.new('Bruce', 18, true )
    registrant_2 = Registrant.new('Penny', 16 )
    registrant_3 = Registrant.new('Tucker', 15 )
    facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014'})
    facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
    facility_1.add_service('Written Test')
    facility_1.administer_written_test(registrant_1)
    expect(facility_1.administer_road_test(registrant_3)).to eq(false)
    registrant_3.earn_permit
    expect(facility_1.administer_road_test(registrant_3)).to eq(false)
    expect(registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
    expect(facility_1.administer_road_test(registrant_1)).to eq(false)
    expect(facility_1.add_service("Road Test")).to eq(["Written Test", "Road Test"])
    expect(facility_1.administer_road_test(registrant_1)).to eq(true)
    expect(registrant_1.license_data).to eq({:written=>true, :license=>true, :renewed=>false})
    registrant_2.earn_permit
    facility_1.administer_written_test(registrant_2)
    expect(registrant_2.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
    expect(facility_1.administer_road_test(registrant_2)).to eq(true)
    expect(registrant_2.license_data).to eq({:written=>true, :license=>true, :renewed=>false})
  end

# Renew License
  it "can renew license but only if had license before" do
    registrant_1 = Registrant.new('Bruce', 18, true )
    registrant_2 = Registrant.new('Penny', 16 )
    registrant_3 = Registrant.new('Tucker', 15 )
    facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014'})
    facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
    facility_1.add_service("Written Test")
    facility_1.add_service("Road Test")
    registrant_3.earn_permit
    registrant_2.earn_permit
    facility_1.administer_written_test(registrant_1)
    facility_1.administer_written_test(registrant_2)
    facility_1.administer_road_test(registrant_1)
    facility_1.administer_road_test(registrant_2)
    expect(facility_1.renew_drivers_license(registrant_1)).to eq(false)
    expect(facility_1.add_service('Renew License')).to eq(["Written Test", "Road Test", "Renew License"])
    expect(facility_1.renew_drivers_license(registrant_1)).to eq(true)
    expect(registrant_1.license_data).to eq({:written=>true, :license=>true, :renewed=>true})
    expect(facility_1.renew_drivers_license(registrant_3)).to eq(false)
    expect(registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
    expect(facility_1.renew_drivers_license(registrant_2)).to eq(true)
    expect(registrant_2.license_data).to eq({:written=>true, :license=>true, :renewed=>true})
  end
end
  