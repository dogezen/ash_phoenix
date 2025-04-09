defmodule AshPhoenix do
  @moduledoc """
  An extension to add form builders to the code interface.

  There is currently no DSL for this extension.

  This defines a `form_to_<name>` function for each code interface
  function. Positional arguments are ignored, given that in forms,
  all input typically comes from the `params` map.

  The generated function passes all options through to
  `AshPhoenix.Form.for_action/3`

  Update and destroy actions take the record being updated/destroyed
  as the first argument.

  For example, given this code interface definition on a domain
  called `MyApp.Accounts`:

  ```elixir
  resources do
    resource MyApp.Accounts.User do
      define :register_with_password, args: [:email, :password]
      define :update_user, action: :update, args: [:email, :password]
    end
  end
  ```

  Adding the `AshPhoenix` extension would define 
  `form_to_register_with_password/2`.

  ## Usage

  Without options:

  ```elixir
  MyApp.Accounts.form_to_register_with_password()
  #=> %AshPhoenix.Form{}
  ```

  With options:

  ```elixir
  MyApp.Accounts.form_to_register_with_password(params: %{"email" => "placeholder@email"})
  #=> %AshPhoenix.Form{}
  ```

  With 

  ```elixir
  MyApp.Accounts.form_to_update_user(params: %{"email" => "placeholder@email"})
  #=> %AshPhoenix.Form{}
  ```
  """

  defmodule FormDefinition do
    defstruct [:name, :args]
  end

  @form %Spark.Dsl.Entity{
    name: :form,
    target: FormDefinition,
    describe: "Customize the definition of a form for a code inteface",
    examples: [
      """
      # customize the generated `form_to_create_student` function
      # args defaults to empty for form definitions
      form :create_student, args: [:school_id]
      """
    ],
    args: [:name],
    schema: [
      name: [
        type: :atom,
        doc: "The name of the interface to modify. Must match an existing interface definition."
      ],
      args: [
        type: {:list, {:or, [:atom, {:tagged_tuple, :optional, :atom}]}},
        doc:
          "Map specific arguments to named inputs. Can provide any argument/attributes that the action allows."
      ]
    ]
  }

  @forms %Spark.Dsl.Section{
    name: :forms,
    describe: "Customize the definition of forms for code interfaces",
    examples: [
      """
      forms do 
        # customize the generated `form_to_create_student` function
        form :create_student, args: [:school_id]
      end
      """
    ],
    entities: [
      @form
    ]
  }

  use Spark.Dsl.Extension,
    verifiers: [AshPhoenix.Verifiers.VerifyFormDefinitions],
    transformers: [AshPhoenix.Transformers.AddFormCodeInterfaces],
    sections: [@forms]
end
