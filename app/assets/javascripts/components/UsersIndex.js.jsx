class UsersIndex extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      users: []
    };
  }

  componentWillMount() {
    if (!$.auth.user.id || ($.auth.user.role == BASIC_ROLE)) {
      return;
    }

    var self = this;
    var usersLookupPath = '/api/v1/users';
    $.getJSON(usersLookupPath)
      .then(function( resp ) {
        self.setState({ users: resp.data })
      })
      .fail(function() {
        Alerts.add('danger', 'Unable to retrieve users. Please try again.').update();
      });
  }

  handleCreateUser() {
    window.location.assign('/#/users/new');
  }

  render() {
    if (!$.auth.user.id) {
      Alerts.add('warning', 'Login required.');
      window.location.assign('/#/');
      return null;
    }
    if ($.auth.user.role == BASIC_ROLE) {
      Alerts.add('danger', 'Unauthorized Access.');
      window.location.assign('/#/');
      return null;
    }

    return (
      <div>
        <div className="intro">
          <div>
            <div className="pull-left"
                 style={{margin:'0.6rem'}}>
               Below is the set of users currently registered within the system.
            </div>
            <div className="pull-right">
              <input type="button" value="Add User" className="btn btn-success" onClick={this.handleCreateUser.bind(this)} />
            </div>
          </div>
          <div className="clearfix"></div>
        </div>
        <UserList users={this.state.users} />
      </div>
    );
  }

};