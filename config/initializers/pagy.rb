# Pagy initializer file (6.5.0)
# See: https://ddnexus.github.io/pagy/docs/api/pagy#configuration

# Instance variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#instance-variables
Pagy::DEFAULT[:limit] = 12  # default items per page
Pagy::DEFAULT[:size]  = 9   # nav bar links

# Rails: Enable the metadata extra for all the controller actions
require 'pagy/extras/metadata'

# Searchkick extra for easy integration with Searchkick
# require 'pagy/extras/searchkick'

# Overflow extra: Allow for easy handling of overflowing pages
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page

# Support for countless extra (pagination without counts)
# require 'pagy/extras/countless'