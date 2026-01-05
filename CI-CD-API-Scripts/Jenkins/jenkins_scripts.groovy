//Use this Script to delete Jenkins User accounts
import hudson.model.User

def usersToDelete = ['USERNAME', 'USERNAME', 'USERNAME', 'USERNAME', 'USERNAME', 'USERNAME'] // Add usernames to this list

usersToDelete.each { username ->
    def user = User.get(username)
    user?.delete()
}

//Gets all Jenkins users
User.getAll().each { println it.getFullName() } 



//gets all jenkins pipelines
import jenkins.model.Jenkins
import hudson.model.TopLevelItem

Jenkins.instance.getAllItems(TopLevelItem).each { item ->
    if (!(item.fullName.contains('/') || item.fullName.startsWith("plugin"))) { // Exclude branches and plugins
        println item.fullName
    }
}


// gets all users email
import hudson.model.User

// Get all users and print their email addresses
User.getAll().each { user ->
    def email = user.getProperty(hudson.tasks.Mailer.UserProperty)?.getAddress()
    if (email) {
        println email
    }
}


// gets all users usernames
import hudson.model.User

// Get all users and print their usernames
User.getAll().each { user ->
    println user.getId()
}