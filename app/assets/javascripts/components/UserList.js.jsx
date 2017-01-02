class UserList extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      users: (this.props.users || [])
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.users != this.state.users) {
      this.setState({ users: nextProps.users });
    }
  }

  handleEditUser(userID) {
    window.location.assign('/#/users/' + userID + '/edit');
  }

  render() {
    var self = this;
    var userList = [];
    if ( this.state.users.length > 0 ) {
      var cellStyle = {
        verticalAlign: 'middle'
      };
      this.state.users.forEach(function(user) {
        var user_name = user.name;
        // Enable link for admin users to load meal details for users.
        if ($.auth.user.role == ADMIN_ROLE) {
          user_name = (<Link to={'/users/' + user.id}>{user.name}</Link>);
        }
        userList.push(
          <tr key={"user-" + user.id}
              className="user-row">
            <td className="name" style={cellStyle}>
              {user_name}
            </td>
            <td className="email" style={cellStyle}>{user.email}</td>
            <td className="role" style={cellStyle}>{user.role}</td>
            <td className="created-at text-center" style={cellStyle}>
              {moment(user.created_at).format("MMM Do YYYY [at] hh:mm a")}
            </td>
            <td className="actions text-center" style={cellStyle}>
              <input type="button"
                     value="Edit"
                     className="btn btn-sm btn-warning"
                     onClick={self.handleEditUser.bind(self, user.id)}/>
            </td>
          </tr>
        );
      });
    } else {
      userList = (
        <tr className="info">
          <td colSpan="5"
              className="text-center">
            Retrieving users...
          </td>
        </tr>
      );
    }

    return (
      <div className="users table-responsive">
      <table className="table table-striped table-hover">
        <thead>
          <tr className="text-center">
            <th className="name text-center">Name</th>
            <th className="email text-center">Email</th>
            <th className="role text-center">Role</th>
            <th className="created-at text-center">Created At</th>
            <th className="actions text-center">Actions</th>
          </tr>
        </thead>
        <tbody>
          {userList}
        </tbody>
      </table>
      </div>
    );
  }
};

