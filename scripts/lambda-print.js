export const handler = async (event) => {
  console.log(`event = ${JSON.stringify(event)}`);

  // TODO implement
  const response = {
    statusCode: 200,
    body: JSON.stringify('Hello from Lambda!'),
  };
  return response;
};