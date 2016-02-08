# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Exceptions
  class UserDoesNotExist < StandardError; end
  class UserCreationFailed < StandardError; end
  class AuthenticationFailed < StandardError; end
  class DecryptFailed < StandardError; end
  class UnknownAuthenticationMethod < StandardError; end
end
