class UserForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      userID: (this.props.userID || null),
      name: '',
      email: '',
      password: '',
      passwordConfirmation: '',
      dailyCalorieTarget: '',
      role: ''
    };

    if (this.props.user) {
      var user = this.props.user;
      this.state = {
        name: (user.name || this.state.name),
        email: (user.email || this.state.email),
        dailyCalorieTarget: (user.daily_calorie_target || this.state.dailyCalorieTarget),
        role: (user.role || this.state.role)
      };
    }

    // Ignore the role attribute entirely if the user is not permitted to modify it.
    this.state.permittedRoles = this.getPermittedRoles();
    if (this.state.role && this.state.permittedRoles.indexOf(this.state.role) < 0) {
      delete this.state.role;
    }
  }

  getPermittedRoles() {
    // Users are only permitted to assign their role or lower to users.
    if ($.auth.user) {
      var roleKeys = Object.keys(ROLES);
      var maxRoleIndex = roleKeys.indexOf($.auth.user.role);
      if (maxRoleIndex >= 0) {
        return roleKeys.slice(0, maxRoleIndex + 1);
      }
    }
    return [];
  }

  updateName(event) {
    this.setState({ name: event.target.value });
  }
  updateEmail(event) {
    this.setState({ email: event.target.value });
  }
  updatePassword(event) {
    this.setState({ password: event.target.value });
  }
  updatePasswordConfirmation(event) {
    this.setState({ passwordConfirmation: event.target.value });
  }
  updateDailyCalorieTarget(event) {
    this.setState({ dailyCalorieTarget: event.target.value });
  }
  updateRole(event) {
    this.setState({ role: event.target.value });
  }

  handleSubmit(event) {
    event.preventDefault();

    if ( !this.isFormValid() ) {
      return;
    }

    var userAttrs = this.state;
    delete userAttrs.permittedRoles;

    this.props.handleFormSubmit(userAttrs);
  }

  isFormValid() {
    $('input').parent('.form-group').removeClass('has-error');
    if (this.state.password && this.state.password.length > 0) {
      if (this.state.password.length < 8) {
        Alerts.add('danger', 'Passwords is too short.').update();
        $('input[name="password"]').parent('.form-group').addClass('has-error');
        return false;
      }
      if (this.state.password.length > 128) {
        Alerts.add('danger', 'Passwords is too long.').update();
        $('input[name="password"]').parent('.form-group').addClass('has-error');
        return false;
      }
      if (this.state.password != this.state.passwordConfirmation) {
        Alerts.add('danger', 'Both passwords must match.').update();
        $('input[name="password-confirmation"]').parent('.form-group').addClass('has-error');
        return false;
      }
    }

    return true;
  }

  render() {
    var roleFormField = this.renderRoleFormField();
    return (
        <form onSubmit={this.handleSubmit.bind(this)}>
          <div className="form-group">
            <label>Name</label>
            <input type="text"
                   name="name"
                   className="form-control"
                   placeholder="John Doe"
                   required={this.props.requireCompleteRecord}
                   value={this.state.name}
                   onChange={this.updateName.bind(this)} />
          </div>
          <div className="form-group">
            <label>Email</label>
            <input type="text"
                   name="email"
                   className="form-control"
                   placeholder="john.doe@gmail.com"
                   required={this.props.requireCompleteRecord}
                   value={this.state.email}
                   onChange={this.updateEmail.bind(this)} />
          </div>
          <div className="form-group">
            <label>Password</label>
            <input type="password"
                   name="password"
                   className="form-control"
                   required={this.props.requireCompleteRecord}
                   value={this.state.password}
                   onChange={this.updatePassword.bind(this)} />
          </div>
          <div className="form-group">
            <label>Password Confirmation</label>
            <input type="password"
                   name="password-confirmation"
                   className="form-control"
                   required={this.props.requireCompleteRecord}
                   value={this.state.passwordConfirmation}
                   onChange={this.updatePasswordConfirmation.bind(this)} />
          </div>
          <div className="form-group">
            <label>Daily Calorie Target</label>
            <input type="number"
                   name="daily-calorie-target"
                   className="form-control"
                   placeholder="2000"
                   required={this.props.requireCompleteRecord}
                   step="1"
                   min="0"
                   max="9999"
                   value={this.state.dailyCalorieTarget}
                   onChange={this.updateDailyCalorieTarget.bind(this)} />
          </div>
          {roleFormField}
          <div className="actions">
            <input type="submit"
                   className="btn btn-success"
                   value={this.props.submitAction} />
          </div>
        </form>
      );
  }

  renderRoleFormField() {
    // Only display role options if there are multiple to choose from and the selected user's role is permitted.
    if (this.state.role == null || !this.state.permittedRoles || this.state.permittedRoles.length <= 1) {
      return null;
    }

    var roleOptions = this.renderRoleSelectOptions();
    if (roleOptions.length > 1) {
      return (
        <div className="form-group">
          <label>Role</label>
          <select name="role"
                  className="form-control"
                  required={true}
                  value={this.state.role}
                  onChange={this.updateRole.bind(this)}>
             {roleOptions}
           </select>
        </div>
      );
    }

    return null;
  }

  renderRoleSelectOptions() {
    var roleOptions = [];
    // Only display the roles that this user is permitted to assign.
    this.state.permittedRoles.forEach(function(key) {
      roleOptions.push(
        <option key={'role-' + key} value={key}>{ROLES[key]}</option>
      );
    });
    return roleOptions;
  }
};
