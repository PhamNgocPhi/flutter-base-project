import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.phipham.fluenary.dev"
            resValue(type = "string", name = "app_name", value = "Fluenary Dev")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.phipham.fluenary.stg"
            resValue(type = "string", name = "app_name", value = "Fluenary Stg")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.phipham.fluenary"
            resValue(type = "string", name = "app_name", value = "Fluenary")
        }
    }

    buildFeatures.resValues = true
}