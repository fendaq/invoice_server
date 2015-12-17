class Api < Cuba
  define do
    on 'services' do
      on get, root do
        json ['bjds', 'lngs', 'lnds']
      end
    end
  end
end