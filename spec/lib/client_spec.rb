# frozen_string_literal: true

# Gnfinder is a namespace module for gndinfer gem.
describe Gnfinder::Client do
  let(:subject) { Gnfinder::Client.new }

  describe '#ping' do
    it 'connects to the server' do
      expect(subject.ping).to eq 'pong'
    end
  end

  describe '#find_names' do
    it 'returns list of name_strings' do
      names = subject.find_names('Pardosa moesta is a spider')
      expect(names[0].name).to eq 'Pardosa moesta'
      expect(names[0].verbatim).to eq 'Pardosa moesta'
    end

    it 'supports with_bayes option' do
      names = subject.find_names('Pardosa moesta is a spider')
      expect(names[0].odds).to eq 0.0

      opts = { with_bayes: true }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].odds).to be > 10.0
    end

    it 'supports language option' do
      names = subject.find_names('Pardosa moesta is a spider')
      expect(names[0].odds).to eq 0.0

      opts = { language: 'eng' }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].odds).to be > 10.0

      opts = { language: 'deu' }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].odds).to be > 10.0
    end

    it 'silently ignores unknown language' do
      names = subject.find_names('Pardosa moesta is a spider')
      expect(names[0].odds).to eq 0.0

      opts = { language: 'whatisit' }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].odds).to eq 0.0
    end

    it 'supports verification option' do
      opts = { with_verification: true, language: 'eng' }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].verification.best_result.match_type).to eq :EXACT
    end

    it 'supports verification with sources' do
      opts = { with_verification: true, sources: [1, 4], language: 'eng' }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].verification.preferred_results[0].data_source_title)
        .to eq 'Catalogue of Life'
      expect(names[0].verification.preferred_results[1].data_source_title)
        .to eq 'NCBI'
      expect(names[0].verification.best_result.data_source_title)
        .to eq 'Catalogue of Life'
    end

    it 'returns the position of a name in a text' do
      names = subject.find_names('Pardosa moesta is a spider')
      expect(names[0].offset_start).to eq 0
      expect(names[0].offset_end).to eq 14
    end

    it 'works with utf8 text' do
      names = subject.find_names('Pedicia apusenica (Ujvárosi and Starý 2003)')
      expect(names[0].name).to eq 'Pedicia apusenica'
    end
  end
end
