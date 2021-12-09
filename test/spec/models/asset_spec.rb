require 'spec_helper'

RSpec.describe Asset, type: :model do
  it "asignacion valida" do
    result = 3
    expect(result).to   eq(3)
  end

  it "validacion factory asset" do
    expect(FactoryGirl.create(:asset)).to be_valid
  end

end
