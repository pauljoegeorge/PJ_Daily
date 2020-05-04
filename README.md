# PJ_DAILY

A serverless project for daily meeting related or quick notes 

## Requirement:
  - Ruby version 2.5.x
  - I use `ruby-2.5.1`
  
## Setup
- Install gem `jets`
   - `$ gem install jets`
- Install bundler
  - `$ gem install bundler`
- clone the repository
  - `$ git clone https://github.com/pauljoegeorge/PJ_Daily.git`
- Make changes to DB config
   - `config/database.yml`
- Run bundle install
  - `$ bundle i`
- create DB and migrate
  - `$ bundle exec rails db:create`
  - `$ bundle exec rails db:migrate`
- Start the server locally 
  - `$ bundle exec jets server --host 0.0.0.0`
  
## How to deploy?
### prerequisite
   - AWS credentials
    - if Lambda function and RDS instance are expected to be within a VPC
      - You should have security group ID, and subnets
        - The Lambda functions vpc_config need to contain private subnets that have a NAT Gateway
        - for more info: 
          - https://rubyonjets.com/docs/considerations/vpc/
          
### Steps
   - create .env.development.remote file in project directory
    - Add DB credentials
      - https://rubyonjets.com/quick-start/
    - if Lambda function is expected be  within VPC:
      - Add to `config/environments/development.rb`: 
      ```
        Jets.application.configure do
          config.function.vpc_config = {
            security_group_ids: %w[sg-1 sg-2],
            subnet_ids: %w[subnet-1 subnet-2 xxxx],
          }
        end
      ```
      - for more info:
        - https://rubyonjets.com/docs/considerations/vpc/
     - Finally deploy:
       - JETS_ENV=development JETS_REMOTE_ENV=1 AWS_PROFILE={AWS_PROFILE} bundle exec jets deploy
     
     
## Delete deployment: 
  JETS_ENV=development JETS_REMOTE_ENV=1 AWS_PROFILE={AWS_PROFILE} bundle exec jets delete
