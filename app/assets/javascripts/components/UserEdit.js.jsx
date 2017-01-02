class UserEdit extends React.Component {
  constructor(props) {
    super(props);

    var currentDate = new Date();
    this.state = {
      userID: (this.props.params.userID || $.auth.user.id)
    };
  }

  componentWillMount() {
    if (!$.auth.user.id ||
        ($.auth.user.role == BASIC_ROLE && $.auth.user.id != this.state.userID)) {
      return;
    }

    var self = this;
    var userLookupPath = '/api/v1/users/' + this.state.userID;
    $.getJSON(userLookupPath)
      .then(function( resp ) {
        self.setState({ user: resp.data })
      })
      .fail(function() {
        Alerts.add('danger', 'Unable to modify the user at this time. Please try again.');
        var redirectPath = '/#/dashboard';
        if ($.auth.user.id != this.state.userID) {
          redirectPath = '/#/users';
        }
        window.location.assign(redirectPath);
      });
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.userID != this.props.params.userID) {
      this.setState({ userID: (nextProps.params.userID || $.auth.user.id) });
    }
  }

  handleFormSubmit(formValues) {
    Alerts.add('info', 'Updating user....').update();

    var userAttrs = {
      name: formValues.name,
      email: formValues.email,
      password: formValues.password,
      role: formValues.role,
      daily_calorie_target: formValues.dailyCalorieTarget
    };
    this.updateUser(this.state.userID, userAttrs);
  }

  updateUser(userID, userAttrs) {
    var self = this;

    var path = '/api/v1/users/' + userID;
    $.ajax({
      type: "PUT",
      url: path,
      data: userAttrs
    })
    .done(function() {
      self.handleUpdateSuccess();
    })
    .fail(function() {
      self.handleUpdateFailure();
    });
  }

  handleUpdateSuccess() {
    Alerts.add('success', 'Successfully updated the user.');
    var redirectPath = '/#/dashboard';
    if ($.auth.user.id != this.state.userID) {
      redirectPath = '/#/users';
    }
    window.location.assign(redirectPath);
  }
  handleUpdateFailure() {
    Alerts.add('danger', 'Unable to update the user.').update();
  }

  handleDeleteUser() {
    Alerts.add('danger', 'Deleting user....').update();

    this.deleteUser(this.state.userID);
  }

  deleteUser(userID) {
    var self = this;

    var path = '/api/v1/users/' + userID
    $.ajax({
      type: "DELETE",
      url: path
    })
    .done(function() {
      self.handleDeleteSuccess();
    })
    .fail(function() {
      self.handleDeleteFailure();
    });
  }

  handleDeleteSuccess() {
    Alerts.add('success', 'Successfully deleted the user.');

    if ($.auth.user.id != this.state.userID) {
      window.location.assign('/#/users');
    } else {
      $.auth.validateToken()
        .always(function() { window.location.assign('/#/'); });
    }
  }
  handleDeleteFailure() {
    Alerts.add('danger', 'Unable to delete the user.').update();
  }

  render() {
    if (!$.auth.user.id) {
      Alerts.add('warning', 'Login required.');
      window.location.assign('/#/');
      return null;
    }
    if ($.auth.user.role == BASIC_ROLE && $.auth.user.id != this.state.userID) {
      Alerts.add('danger', 'Unauthorized Access.');
      window.location.assign('/#/');
      return null;
    }

    var form = '';
    if (this.state.user) {
      form = (
        <UserForm handleFormSubmit={this.handleFormSubmit.bind(this)}
                  userID={this.state.userID}
                  user={this.state.user}
                  submitAction={'Update'}
                  requireCompleteRecord={false} />
      );
    }

    return (
      <div>
        <div className="intro">
          <div className="pull-left"
               style={{margin:'0.6rem'}} >
             Update the user using the form below:
           </div>
          <button type="button"
                  className="btn btn-danger pull-right"
                  onClick={this.handleDeleteUser.bind(this)}>
            Delete User
          </button>
          <div className="clearfix"></div>
        </div>
        {form}
    </div>
    );
  }
};