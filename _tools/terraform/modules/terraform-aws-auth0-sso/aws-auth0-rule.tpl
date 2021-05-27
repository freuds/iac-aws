function (user, context, callback) {
    if (context.clientID === '${auth0_console_client_id}' || context.clientID === '${auth0_cli_client_id}'){
        const request = require('request');
        const rp = require('request-promise@1.0.2');
        let data = '';

        var options = {
          method: 'GET',
          url: '${aws_users_bucket_path}',
          json: true
        };

        rp(options)
          .then(function(jsonData){
          const entries = Object.entries(jsonData);
          for (const [key, value] of entries){
            if (value.gcloud_email === user.email || value.github_user.toUpperCase() === user.nickname.toUpperCase()){
              if (value.aws_roles.includes('devops')){
              user.awsRole = [ '${admin_arn},${auth0_provider_arn}','${user_arn},${auth0_provider_arn}'];
              } else if (value.aws_roles.includes('user')){
                user.awsRole = [ '${user_arn},${auth0_provider_arn}'];
              }
              user.awsRoleSession = user.nickname;
                user.time = ${user_max_lifetime};
              context.samlConfiguration.mappings = {
                'https://aws.amazon.com/SAML/Attributes/Role': 'awsRole',
                'https://aws.amazon.com/SAML/Attributes/RoleSessionName': 'awsRoleSession',
                'https://aws.amazon.com/SAML/Attributes/SessionDuration': 'time'
              };
              return callback(null, user, context);
            }
          }
          callback(new UnauthorizedError('You are not allowed to log here. ¯\_(ツ)_/¯ '), user, context);
          });
    }
    else {
      callback(null, user, context);
    }
}
