var RouteHandler = ReactRouter.RouteHandler,
    Link = ReactRouter.Link;

// Global Constants:
var BASIC_ROLE = 'basic';
var USER_MANAGER_ROLE = 'user_manager';
var ADMIN_ROLE = 'admin';
var ROLES={
  basic: 'Basic',
  user_manager: 'User Manager',
  admin: 'Admin'
};

class App extends React.Component {
  constructor(props) {
    super(props);

    this.state = { userLoaded: false };
  }

  componentWillMount() {
    var self = this;
    $.auth.configure({
      apiUrl:                '/api/v1',
      signOutPath:           '/auth/sign_out',
      emailSignInPath:       '/auth/sign_in',
      tokenValidationPath:   '/auth/validate_token',
      storage:               'cookies',

      tokenFormat: {
        "access-token": "{{ access-token }}",
        "token-type":   "Bearer",
        client:         "{{ client }}",
        expiry:         "{{ expiry }}",
        uid:            "{{ uid }}"
      },

      parseExpiry: function(headers){
        // convert from ruby time (seconds) to js time (millis)
        return (parseInt(headers['expiry'], 10) * 1000) || null;
      },

      handleLoginResponse: function(resp) {
        return resp.data;
      },

      handleTokenValidationResponse: function(resp) {
        return resp.data;
      }

    })
    .then(function() {
      self.setState({ userLoaded: true });
    })
    .fail(function() {
      self.setState({ userLoaded: true });
    });
  }

  render() {
    var page = '';

    // Until we know who/if a current user is logged in, it's not safe to load the page content.
    if ( this.state.userLoaded ) {
      page = (
        <div>
          <Header />
          <div className="container header-spacer">
            <Alerts />
            <RouteHandler {...this.props} />
          </div>
        </div>
      );
    }

    return (
      <div>
        {page}
      </div>
    );
  }

};