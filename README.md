# README

This application powers a calorie tracking service that allows users to sign up, track their meals, and review their progress toward maintain a daily maximum calorie intake. Users can sign up by providing basic account information and a daily target for their calorie intake. Once they've created an account, users can record each meal they eat, specifying a description, the date, the time, and the total calorie count for the meal. A dashboard displays the meals recorded for each day and indicates whether they were over or under their specified target for a given day.

## Design

The following are a few noteworthy aspects of the design of this service.

### Roles

The following are the set of roles used within the system and the abilities of each role:

* Basic User: Allowed to create and log into their account; and record, update, and delete their own meals.
* User Manager: Allowed to perform all actions of a basic user and additionally create, update, and delete users across the entire system.
* Admin User: Allowed to perform all actions of a user manager and additionally create, update, and delete meals across any user of the entire system. 

## Development

### Dependencies

* Ruby: This application is built using the Ruby language. Please make sure you have the appropriate version installed. This can be found in the `Gemfile`. As of the writing of this document, the application is built to run on Ruby 2.3.1.
* Bundler: Bundler is a common ruby library package management tool. This application uses it extensively to manage and maintain the set of libraries used.
* PostgreSQL: The database adapter used by the application is the PostgreSQL adapter. Please make sure you have a database available for the application to connect and have setup your environment variables properly to connect to it.

### Setup Steps

1. Install Dependencies/Libraries:
  * Run `bundle install`
1. Setup Environment Variables:
  * Copy the `.env.test` file to `.env`.
  * Modify the values of this file to be appropriate for your environment.
1. Setup the Database:
  * Run `bundle exec rake db:setup`.
1. Run the Automated Test Suite:
  * Run `bundle exec rspec spec/` and verify that all tests pass.
1. Launch the Application:
  * Run `bundle exec rails server`

## More Information

Additional documentation can be found in the `doc` folder, including:

* (doc/api.paw)[doc/api.paw]: A (Paw)[https://paw.cloud/] file containing examples of how the APIs exposed by this service can be accessed.
* (doc/apiary.apib)[doc/apiary.apib]: An API blueprint document outlining the set of APIs exposed by this service. This documentation can also be found on (Apiary)[http://docs.calorietrackerapi.apiary.io/#].