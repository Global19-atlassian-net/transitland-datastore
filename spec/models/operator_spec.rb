# == Schema Information
#
# Table name: current_operators
#
#  id                                 :integer          not null, primary key
#  name                               :string
#  tags                               :hstore
#  created_at                         :datetime
#  updated_at                         :datetime
#  onestop_id                         :string
#  geometry                           :geography({:srid geometry, 4326
#  created_or_updated_in_changeset_id :integer
#  version                            :integer
#
# Indexes
#
#  #c_operators_cu_in_changeset_id_index  (created_or_updated_in_changeset_id)
#  index_current_operators_on_onestop_id  (onestop_id) UNIQUE
#

describe Operator do
  it 'can be created' do
    operator = create(:operator)
    expect(Operator.exists?(operator.id)).to be true
  end

  it 'can be found by identifier and/or name' do
    bart = create(:operator, name: 'BART')
    bart.identifiers.create(identifier: 'Bay Area Rapid Transit')
    sfmta = create(:operator, name: 'SFMTA')
    expect(Operator.with_identifier('Bay Area Rapid Transit')).to match_array([bart])
    expect(Operator.with_identifier_or_name('BART')).to match_array([bart])
    expect(Operator.with_identifier('SFMTA')).to be_empty
    expect(Operator.with_identifier_or_name('SFMTA')).to match_array([sfmta])
  end
end