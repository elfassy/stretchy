require 'spec_helper'

describe Stretchy::Clauses::MatchClause do
  let(:base) { Stretchy::Clauses::Base.new }
  subject { described_class.new(base) }

  it 'creates a temporary instance' do
    expect(described_class.tmp).to be_a(described_class)
  end

  context 'initializes with' do
    specify 'nil' do
      instance = described_class.new(base)
      expect(instance.match_builder.any?).to eq(false)
      expect(instance.inverse?).to eq(false)
    end

    specify 'string' do
      instance = described_class.new(base, 'match string')
      expect(instance.match_builder.matches['_all']).to include('match string')
      expect(instance.inverse?).to eq(false)
    end

    specify 'options' do
      instance = described_class.new(base, field_one: 'one', field_two: 'two')
      expect(instance.match_builder.matches[:field_one]).to include('one')
      expect(instance.match_builder.matches[:field_two]).to include('two')
      expect(instance.inverse?).to eq(false)
    end

    specify 'inverse options' do
      instance = described_class.new(base, field_one: 'one', field_two: 'two', inverse: true)
      expect(instance.match_builder.antimatches[:field_one]).to include('one')
      expect(instance.match_builder.antimatches[:field_two]).to include('two')
      expect(instance.inverse?).to eq(true)
    end

    specify 'options and base options' do
      instance = described_class.new(base, {field_one: 'one', field_two: 'two'}, inverse: true)
      expect(instance.match_builder.antimatches[:field_one]).to include('one')
      expect(instance.match_builder.antimatches[:field_two]).to include('two')
      expect(instance.inverse?).to eq(true)
    end

    specify 'should options' do
      instance = described_class.new(base, {field_one: 'one', should: true})
      expect(instance.match_builder.shouldmatches[:field_one]).to include('one')
      expect(instance.should?).to eq(true)
      expect(instance.inverse?).to eq(false)
    end

    specify 'should + inverse' do
      instance = described_class.new(base, field_one: 'one', should: true, inverse: true)
      expect(instance.match_builder.shouldnotmatches[:field_one]).to include('one')
      expect(instance.should?).to eq(true)
      expect(instance.inverse?).to eq(true)
    end

    specify 'should + inverse secondary' do
      instance = described_class.new(base, {field_one: 'one'}, should: true, inverse: true)
      expect(instance.match_builder.shouldnotmatches[:field_one]).to include('one')
      expect(instance.should?).to eq(true)
      expect(instance.inverse?).to eq(true)
    end
  end

  it 'inverts via not' do
    expect(subject.not).to be_a(described_class)
    expect(subject.not.inverse?).to eq(true)
  end

  it 'switches via should' do
    expect(subject.should.should?).to eq(true)
  end

  it 'initializes inverse via string' do
    instance = subject.not('not matching string')
    expect(instance).to be_a(described_class)
    expect(instance.inverse?).to eq(true)
    expect(instance.match_builder.antimatches['_all']).to include('not matching string')
  end

  it 'initializes inverse with options' do
    instance = subject.not(string_field: 'not matching string')
    expect(instance).to be_a(described_class)
    expect(instance.inverse?).to eq(true)
    expect(instance.match_builder.antimatches[:string_field]).to include('not matching string')
  end

  it 'chains not options' do
    instance = subject.not(field_one: 'one').match('match_all')
    builder = subject.match_builder
    expect(builder.matches['_all']).to include('match_all')
    expect(builder.antimatches[:field_one]).to include('one')
  end

  it 'chains should options' do
    instance = subject.should(field_one: 'one').match('match_all')
    builder = subject.match_builder
    expect(builder.matches['_all']).to include('match_all')
    expect(builder.shouldmatches[:field_one]).to include('one')
  end

  it 'chains should and not options' do
    instance = subject.should.not(field_one: 'one').should(field_two: 'two')
    builder = subject.match_builder
    expect(builder.shouldmatches[:field_two]).to include('two')
    expect(builder.shouldnotmatches[:field_one]).to include('one')
  end

  it 'chains should and match options' do
    instance = subject.should(field_one: 'one').not(field_two: 'two').match('match_all')
    builder = subject.match_builder
    expect(builder.shouldmatches[:field_one]).to include('one')
    expect(builder.shouldnotmatches[:field_two]).to include('two')
  end

  it 'builds a query filter boost' do
    boost = described_class.new(base, 'match all string').to_boost
    expect(boost).to be_a(Stretchy::Boosts::FilterBoost)
  end

end