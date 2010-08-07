This directory is named 'factory' instead of 'factories' to keep FactoryGirl from autoloading it's contents when the gem gets loaded.
That way changes can be made the factory files within without restarting the Spork server.
