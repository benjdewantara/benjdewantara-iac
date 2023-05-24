import boto3

codepipeline_client = boto3.client('codepipeline')
codecommit_client = boto3.client('codecommit')
secretsmanager_client = boto3.client('secretsmanager')


def lambda_handler():
    first_nonsuperseded, previous_nonsuperseded = codepipeline_get_previous_nonsuperseded(
        pipeline_name="codepipeline-codecommitdeploypipeline",
        execution_id_anchor="000577c2-6b6a-4484-b654-b6e957540cb7"
    )

    commit_first = first_nonsuperseded["sourceRevisions"][0]["revisionId"]
    commit_previous = previous_nonsuperseded["sourceRevisions"][0]["revisionId"]

    repository_name = first_nonsuperseded["sourceRevisions"][0]["revisionUrl"]
    repository_name = repository_name.split("/repository/")[1]
    repository_name = repository_name.split("/commit/")[0]

    commits_generator = codecommit_get_commit_range(
        commit_from_inclusive=commit_first,
        commit_to_exclusive=commit_previous,
        repository_name=repository_name)
    commits = list(commits_generator)
    print("commits = {}".format(commits))
    pass


def codecommit_get_commit_range(commit_from_inclusive, commit_to_exclusive, repository_name):
    commit_current = commit_from_inclusive

    while True:
        request = {
            "repositoryName": repository_name,
            "commitId": commit_current
        }

        response = codecommit_client.get_commit(
            **request
        )

        yield commit_current

        commit_parent = response["commit"]["parents"][0]
        if commit_parent == commit_to_exclusive:
            break

        commit_current = commit_parent
        pass
    pass


def codepipeline_get_previous_nonsuperseded(pipeline_name, execution_id_anchor):
    non_superseded_history = codepipeline_get_nonsuperseded(
        pipeline_name=pipeline_name,
        execution_id_anchor=execution_id_anchor
    )

    first = next(non_superseded_history)
    previous = next(non_superseded_history)

    return first, previous


def codepipeline_get_nonsuperseded(pipeline_name, execution_id_anchor):
    has_found_anchor = False
    retrieve_index = 0
    next_token = ""
    while next_token or retrieve_index == 0:
        retrieve_index += 1

        request = {
            "pipelineName": pipeline_name,
            "maxResults": 10,
        }

        if next_token:
            request["nextToken"] = next_token

        response = codepipeline_client.list_pipeline_executions(
            **request
        )

        summaries = response["pipelineExecutionSummaries"]
        summaries = [s for s in summaries if s and "status" in s]
        summaries = [s for s in summaries if s["status"] != "Superseded"]
        summaries = [s for s in summaries if "sourceRevisions" in s]
        summaries = [s for s in summaries if "revisionId" in s["sourceRevisions"][0]]

        for s in summaries:
            if not has_found_anchor:
                if s["pipelineExecutionId"] == execution_id_anchor:
                    has_found_anchor = True
                    yield s
                    continue
            else:
                yield s
                break

        if "nextToken" in response:
            next_token = response["nextToken"]
        else:
            next_token = ""
        pass
    pass


if __name__ == '__main__':
    lambda_handler()
