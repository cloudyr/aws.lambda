# aws.lambda 0.1.6.9000

* New maintainer (@jonthegeek).
* Updated license to GPL-3.
* Deprecated `update_function()` in favor of `update_function_code()` and `update_function_config()`.
* Deprecated `make_function_version()` in favor of `publish_function_version()`.

# aws.lambda 0.1.6

* Change `get_account()` to `get_lambda_account()` to avoid namespace conflict with **aws.iam.**

# aws.lambda 0.1.4

* Bump **aws.signature** dependency to 0.3.4.

# aws.lambda 0.1.3

* Rename alias-related functions to avoid namespace clash with aws.iam.

# aws.lambda 0.1.2

* Update code and documentation.

# aws.lambda 0.1.1

* Initial release.
