import 'package:graphql_flutter/graphql_flutter.dart';

import '../config/app_config.dart';

/// GraphQL client for the Weaviate instance that stores each avatar's
/// recommendations (class `AvatarRec`, vectorized with Cohere).
GraphQLClient getWeaviateApiClient() {
  final Link httpLink = HttpLink(
    AppConfig.weaviateGraphqlUrl,
    defaultHeaders: {"X-Cohere-Api-Key": AppConfig.cohereApiKey},
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer ${AppConfig.weaviateApiKey}',
  );
  final Link link = authLink.concat(httpLink);
  return GraphQLClient(cache: GraphQLCache(), link: link);
}
