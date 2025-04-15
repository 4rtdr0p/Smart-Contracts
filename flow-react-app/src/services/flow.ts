import * as fcl from "@onflow/fcl";
import * as t from "@onflow/types";

// Initialize FCL
fcl.config()
  .put("accessNode.api", "https://rest-testnet.onflow.org") // Testnet access node
  .put("discovery.wallet", "https://fcl-discovery.onflow.org/testnet/authn") // Testnet wallet discovery
  .put("app.detail.title", "Flow React App")
  .put("app.detail.icon", "https://placekitten.com/g/200/200");

export const flowService = {
  // Execute a script on Flow blockchain
  async executeScript(script: string, args: any[] = []) {
    try {
      const result = await fcl.query({
        cadence: script,
        args: (arg: any, t: any) => args,
      });
      console.log(result)
      return result;
    } catch (error) {
      console.error("Error executing script:", error);
      throw error;
    }
  },

  // Get image URL from Flow blockchain
  async getImage() {
    const script = `
    import imgHost from 0xc9bebc18db58bae2

      access(all) fun main(): String {
        return imgHost.img
      }
    `;

    return this.executeScript(script);
  },

  // Authenticate user
  async authenticate() {
    try {
      await fcl.authenticate();
    } catch (error) {
      console.error("Authentication error:", error);
      throw error;
    }
  },

  // Get current user
  async getCurrentUser() {
    try {
      return await fcl.currentUser().snapshot();
    } catch (error) {
      console.error("Error getting current user:", error);
      throw error;
    }
  },

  // Logout user
  async logout() {
    try {
      await fcl.unauthenticate();
    } catch (error) {
      console.error("Logout error:", error);
      throw error;
    }
  }
}; 