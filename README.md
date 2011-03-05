[http://www.opensourcerails.com/projects/29906-EasyBooks](http://www.opensourcerails.com/projects/29906-EasyBooks)

To install:

$ git clone git://github.com/shock/easybooks.git


Edit easybooks/config/database.yml for your database configuration.

$ cd easybooks
$ rake db:create
$ rake db:schema:load

Then start the server:

$ cd easybooks
$ script/server

To create a user, visit /users/new.

This is still very much a work in progress.  It was my first Rails project and it shows.  My goal is to revisit this project and update it using the Rails, HTML, CSS, and JS I have learned since then.


###TODO
* Upgrade Rails to version 3.x.
* Implement scrollable AJAX paging in register view so that only the transactions for the viewable scrolling area are sent from the server
* Enhance AJAX in register view to update balances when CRUD'ing transactions.
* Install Rubble and convert layouts to use it.
* Re-skin with more attractive, modern UI design.
* Support linked transactions for transfers between accounts.
* Support account reconciliation through Web UI.